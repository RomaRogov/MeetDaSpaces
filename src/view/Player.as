package view
{
	import com.greensock.TweenLite;
	import de.exitgames.photon_as3.loadBalancing.model.constants.Constants;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import model.LevelColliders;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import starling.utils.Color;
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class Player extends Sprite
	{
		public static const SPEED_MAX : Number = 3;
		
		//-=-=-=-=-=-=-Emotions declaration-=-=-=-=-=-=-
		public static const emotionList : Array = [ 
		{ s: ":)" , k:0  },
		{ s: ":(" , k:1  },
		{ s: ":'(", k:2  },
		{ s: "^^" , k:3  },
		{ s: "^_^", k:3  },
		{ s: "><" , k:4  },
		{ s: ">_<", k:4  },
		{ s: ">|" , k:4  },
		{ s: "x|" , k:5  },
		{ s: "X|" , k:5  },
		{ s: "x)" , k:5  },
		{ s: "х)" , k:5  },
		{ s: ":D" , k:6  },
		{ s: "=3" , k:7  },
		{ s: ":3" , k:7  },
		{ s: "O_o", k:8  },
		{ s: "О_о", k:8  },
		{ s: "o_O", k:8  },
		{ s: ":0" , k:8  },
		{ s: "=0" , k:8  },
		{ s: "<3" , k:9  },
		{ s: ":*" , k:9  },
		{ s: "=*" , k:9  }
		];
		//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
		private static var faceNames : Array = [ "face", "face2", "face3", "face4", "face5", "face6", "face7", "face8", "face9", "face10" ];
		
		private var _relativePos : Point = new Point();
		private var _targetPos : Point = new Point();
		
		public var active : Boolean = false;
		
		private var _name : String;
		private var _frags : int = 0;
		private var _actorID : int;
		private var _evilActor : int;
		private var _local :Boolean = false;
		
		private var _bodyColor : uint;
		private var _faceColor : uint;
		private var _pushSpeed : Point = new Point( 0, 0 );
		private var _moveSpeed : Point = new Point( 0, 0 );
		
		private var _shakeVal : Number = 0;
		private var _emoTimer : Timer;
		
		private var _prevX : Number = 0;
		private var _prevY : Number = 0;
		
		private var _img : Image;
		private var _imgFrame : int = 0;
		private var _imgTextures : Vector.<Texture>;
		private var _animTimer : Timer;
		
		private var _faceImg : Image;
		
		private var _nameText : TextField;
		
		public function Player( isLocal : Boolean, name : String ) 
		{
			_imgTextures = new Vector.<Texture>();
			_imgTextures.push( AssetStorage.mainAtlas.getTexture( "player_frame1" ) );
			_imgTextures.push( AssetStorage.mainAtlas.getTexture( "player_frame2" ) );
			addChild( _img = new Image( _imgTextures[_imgFrame] ) ); 
			_img.smoothing = TextureSmoothing.NONE;
			_img.pivotX = 8;
			_img.pivotY = 15;
			_img.scaleX = _img.scaleY = 2;
			
			addChild( _faceImg = new Image( AssetStorage.mainAtlas.getTexture( "face" ) ) );
			_faceImg.pivotX = 8;
			_faceImg.pivotY = 15;
			_faceImg.scaleX = _faceImg.scaleY = 2;
			_faceImg.smoothing = TextureSmoothing.NONE;
			
			addChild( _nameText = new TextField( 200, 40, name, "PressStart2P", 12, 0xFFFFFF ) );
			_nameText.filter = BlurFilter.createGlow( 0 );
			
			_local = isLocal;
			if ( !_local )
				active = true;
			
			_emoTimer = new Timer( 5000 );
			_emoTimer.addEventListener( TimerEvent.TIMER, function():void { emotion = 0; } );
			_animTimer = new Timer( 150 );
			_animTimer.addEventListener( TimerEvent.TIMER, function():void { _imgFrame = (_imgFrame == 0) ? 1 : 0; _img.texture = _imgTextures[_imgFrame]; } );
			
			Keyboarder.instance.addEventListener( KeyboardEvent.KEY_DOWN, checkMovement );
			Keyboarder.instance.addEventListener( KeyboardEvent.KEY_UP, checkKeyUp );
			addEventListener( Event.ENTER_FRAME, onFrame );
			
			_name = name;
			
			if ( _local )
				setTimeout( netMoving, 200 );
		}
		
		private function checkMovement( e : KeyboardEvent ):void
		{
			if ( !_local || !active )
				return;
				
			if ( Keyboarder.instance.isKeyPressed( Keyboard.Z ) )
			{
				var side : int = 0;
				if ( Keyboarder.instance.isKeyPressed( Keyboard.LEFT ) )
					side = 3;
				if ( Keyboarder.instance.isKeyPressed( Keyboard.RIGHT ) )
					side = 1;
				if ( Keyboarder.instance.isKeyPressed( Keyboard.UP ) )
					side = 2;
				if ( Keyboarder.instance.isKeyPressed( Keyboard.DOWN ) )
					side = 4;
					
				if ( side != 0 )
				{
					//Preparing data
					var data : Dictionary = new Dictionary();
					data["side"] = side;
					data[Constants.KEY_ACTOR_NO] = PhotonPeer.getInstance().getActorNo();
					PhotonPeer.getInstance().opRaiseEventWithCode( PhotonPeer.CODE_PLAYERPUSH, data );
				}
			}
				
			if ( e )
			{
				if ( Keyboarder.instance.isKeyPressed( Keyboard.LEFT ) )
					_moveSpeed.x = -SPEED_MAX;
				if ( Keyboarder.instance.isKeyPressed( Keyboard.RIGHT ) )
					_moveSpeed.x = SPEED_MAX;
				if ( Keyboarder.instance.isKeyPressed( Keyboard.UP ) )
					_moveSpeed.y = -SPEED_MAX;
				if ( Keyboarder.instance.isKeyPressed( Keyboard.DOWN ) )
					_moveSpeed.y = SPEED_MAX;
			}
			
		}
		
		private function checkKeyUp( e: KeyboardEvent ):void
		{
			if ( !_local || !active )
				return;
				
			if ( e )
			{
				if ( !Keyboarder.instance.isKeyPressed( Keyboard.LEFT ) && !Keyboarder.instance.isKeyPressed( Keyboard.RIGHT ) )
					_moveSpeed.x = 0;
				if ( !Keyboarder.instance.isKeyPressed( Keyboard.UP ) && !Keyboarder.instance.isKeyPressed( Keyboard.DOWN ) )
					_moveSpeed.y = 0;
			}
		}
		
		public function push( side : int ):void
		{
			if ( !_local || !active )
				return;
				
			
			if ( side == 3  )
				_pushSpeed.x = -16;
			if ( side == 1 )
				_pushSpeed.x = 16;
			if ( side == 2 )
				_pushSpeed.y = -16;
			if ( side == 4 )
				_pushSpeed.y = 16;
		}
		
		private function netMoving():void
		{
			if ( _moveSpeed.length > 0 || _pushSpeed.length > 0 )
			{
				//Preparing data
				var data : Dictionary = new Dictionary();
				data["x"] = _targetPos.x;
				data["y"] = _targetPos.y;
				data[Constants.KEY_ACTOR_NO] = PhotonPeer.getInstance().getActorNo();
				PhotonPeer.getInstance().opRaiseEventWithCode( PhotonPeer.CODE_PLAYERMOVE, data );
			}
			setTimeout( netMoving, 200 );
		}
		
		private function onFrame( e:* ):void
		{
			_faceImg.scaleX = _img.scaleX;
			_faceImg.scaleY = _img.scaleY;
			if ( !active )
				return;
				
			if ( _local )
			{
				if ( LevelColliders.checkBlockRect( new Rectangle( playerX - 12 + _moveSpeed.x, playerY - 16, 24 + _moveSpeed.x, 16 ) ) )
				{
					_targetPos.x = _relativePos.x = _prevX;
					_moveSpeed.x = 0;
					_pushSpeed.x = 0;
				}
				if ( LevelColliders.checkBlockRect( new Rectangle( playerX - 12, playerY - 16 + _moveSpeed.y, 24, 16 + _moveSpeed.y ) ) )
				{
					_targetPos.y = _relativePos.y = _prevY;
					_moveSpeed.y = 0;
					_pushSpeed.y = 0;
				}
			}
			
			if ( _local )
			{
				_targetPos = _targetPos.add( _moveSpeed );
				_targetPos = _targetPos.add( _pushSpeed );
				_pushSpeed.x = _pushSpeed.x * .6;
				_pushSpeed.y = _pushSpeed.y * .6;
			}
			
			_prevX = _relativePos.x;
			_prevY = _relativePos.y;
			
			_img.x = _faceImg.x = _relativePos.x + _shakeVal;
			_img.y = _relativePos.y;
			_faceImg.y = _relativePos.y + _imgFrame;
			_nameText.x = _relativePos.x - 100;
			_nameText.y = _relativePos.y - 64;
			
			_relativePos.x += ( _targetPos.x - _relativePos.x ) / 6;
			_relativePos.y += ( _targetPos.y - _relativePos.y ) / 6;
			
			if ( _moveSpeed.length > 0.3 )
				playAnim();
			else
				stopAnim();
			
			if ( (_moveSpeed.length > 0) && _local )
				StarSpace.instance.moveStars( (_relativePos.x - _prevX)*2, (_relativePos.y - _prevY)*2 );
			
			if ( !LevelColliders.checkFloorPoint( _relativePos.add( new Point( 0, -4 ) ) ) && active && _local )
			{
				active = false;
				_moveSpeed = new Point( 0, 0 );
				_pushSpeed = new Point( 0, 0 );
				//TODO: Sprite instead of anim
				TweenLite.to( _img, 1, { scaleX: 0, scaleY: 0, onComplete: function():void
				{
					_img.scaleX = _img.scaleY = 2;
					var newPos : Point = LevelColliders.getRandomSpawn();
					_targetPos = newPos;
					_relativePos = newPos;
					_prevX = newPos.x;
					_prevY = newPos.y;
					active = true;
				} } );
			}
			
			/*if ( !_local )
			{
				x = 0;// _relativePos.x;
				y = 0;// _relativePos.y;
			}*/
			
			_shakeVal = - _shakeVal;
			if ( Math.abs( _shakeVal ) < 0.3 )
				_shakeVal = 0;
			else
				_shakeVal += (_shakeVal < 0 ? 0.2 : -0.2 );
		}
		
		public function parseEmotion( message : String ):void
		{
			_shakeVal = 3;
			for each ( var emo : Object in emotionList )
				if ( message.indexOf( emo.s ) >= 0 )
					emotion = emo.k;
		}
		
		private function stopAnim():void { 
			_animTimer.stop();
		}
		private function playAnim():void { 
			if ( !_animTimer.running )
				_animTimer.start();
		}
		
		public function get isLocal():Boolean { return _local; }
		
		public function get playerX():Number { return _relativePos.x; }
		public function get playerY():Number { return _relativePos.y; }
		public function set relativePos( pos : Point ):void { _relativePos = pos; _targetPos = pos; }
		
		public function get playerName():String { return _name; }
		public function get actorNo():int { return _actorID; }
		public function set actorNo( val : int ):void { _actorID = val; _evilActor = _actorID; }
		
		public function get speed():Number { return _moveSpeed.length; }
		
		public function set targetPos( pos : Point ):void { _targetPos = pos; }
		public function set emotion( val : uint ):void { 
			_faceImg.texture = AssetStorage.mainAtlas.getTexture( faceNames[val] );
			_emoTimer.delay = 5000;
			_emoTimer.start();
		}
		
		public function set bodyColor( val : uint ):void
		{
			_bodyColor = val;
			//hex to rgb
			var bodyr:uint = ((val & 0xFF0000) >> 16);
			var bodyg:uint = ((val & 0x00FF00) >>  8);
			var bodyb:uint = ((val & 0x0000FF)      );
			_img.color = val;
		}
		public function get bodyColor():uint { return _bodyColor; }
		
		public function set faceColor( val : uint ):void
		{
			_faceColor = val;
			//hex to rgb
			var facer:uint = ((val & 0xFF0000) >> 16);
			var faceg:uint = ((val & 0x00FF00) >>  8);
			var faceb:uint = ((val & 0x0000FF)      );
			//_anim.face.transform.colorTransform = new ColorTransform( 1, 1, 1, 1, -255 + facer, -255 + faceg, -255 + faceb );
		}
		public function get faceColor():uint { return _faceColor; }
	}

}