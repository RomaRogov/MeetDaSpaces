package editor 
{
	import editor.tiles.FloorMapTile;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.textures.RenderTexture;
	import starling.textures.Texture;
	import util.FPSCounter;
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class Editor extends Sprite
	{
		private const cellW : int = 32;
		private const cellH : int = 32;
		
		private var mouseX : int = 0;
		private var mouseY : int = 0;
		
		private var shiftX : Number = 0;
		private var shiftY : Number = 0;
		
		private var shiftSpeedX : Number = 0;
		private var shiftSpeedY : Number = 0;
		
		private var mouseDist : Number = 0;
		
		private var backTileImage : Image;
		private var currentTileImage : Image;
		private var objectsContainer : Sprite;
		
		private var floorTextures : Array = [ "floor" ];
		private var wallTextures : Array = [ "wall", "wall_end" ];
		private var curTexName : String = "floor";
		
		private var fpsTF : TextField;
		private var commandTF : TextField;
		
		private var resourcesLoaded : Boolean = false;
		private var stageLoaded : Boolean = false;
		private var inputMode : Boolean = false;
		
		public static var instance : Editor;
		
		public function Editor() 
		{
			instance = this;
			addEventListener( Event.ADDED_TO_STAGE, function(e:*):void { 
				stageLoaded = true;
				if ( resourcesLoaded ) 
					Init();
				} );
		}
		
		public function onResourcesLoaded():void
		{
			resourcesLoaded = true;
				if ( stageLoaded )
					Init();
		}
		
		private function Init():void
		{
			var tileAtlasImage : Image = new Image( AssetStorage.mainAtlas.getTexture( "editor_tile" ) );
			
			//Preparing Image for background
			//Hmm, small hack. I can't manipulate tex coords normally with atlas texture
			//So, I'll render atlas texture to new RenderTexture. Hope it's not so expensive
			var tileTexture : RenderTexture = new RenderTexture( 32, 32 );
			tileTexture.draw( tileAtlasImage );
			tileTexture.repeat = true;
			backTileImage = new Image( tileTexture );
			backTileImage.width = Math.ceil( stage.stageWidth / 32 ) * 32;
			backTileImage.height = Math.ceil( stage.stageHeight / 32 ) * 32;
			addChild( backTileImage );
			//Preparing Image for current tile
			currentTileImage = new Image( AssetStorage.mapAtlas.getTexture( curTexName ) );
			currentTileImage.alpha = 0.5;
			addChild( currentTileImage );
			//Container for level
			addChild( objectsContainer = new Sprite() );
			//FPS counter
			fpsTF = new TextField( 200, 30, "--.- FPS", "PressStart2P", 12, 0xFFFFFF );
			fpsTF.hAlign = "left";
			addChild( fpsTF );
			//Command TF
			commandTF = new TextField( stage.stageWidth, 30, "Press Enter for command", "PressStart2P", 12, 0xFFFFFF );
			commandTF.hAlign = "left";
			commandTF.x = 20;
			commandTF.y = stage.stageHeight - 30;
			addChild( commandTF );
			
			//Listeners
			stage.addEventListener( TouchEvent.TOUCH, onMouseMove );
			addEventListener( Event.ENTER_FRAME, onFrame );
			Keyboarder.instance.addEventListener( KeyboardEvent.KEY_DOWN, processKeyEvents );
		}
		
		private function onFrame( e:* ):void
		{
			if ( !backTileImage || !stage )
				return;

			/* SCROLL BACKROUND */
			var horRepeat : int = Math.ceil( stage.stageWidth  / cellW );
			var verRepeat : int = Math.ceil( stage.stageHeight / cellH );
			var horTextureShift : Number = (-shiftX % cellW) / cellW;
			var verTextureShift : Number = (-shiftY % cellH) / cellH;
			backTileImage.setTexCoords( 0, new Point(             horTextureShift,             verTextureShift ) );
			backTileImage.setTexCoords( 1, new Point( horTextureShift + horRepeat,             verTextureShift ) );
			backTileImage.setTexCoords( 2, new Point(             horTextureShift, verTextureShift + verRepeat ) );
			backTileImage.setTexCoords( 3, new Point( horTextureShift + horRepeat, verTextureShift + verRepeat ) );
			
			objectsContainer.x = shiftX;
			objectsContainer.y = shiftY;
			
			shiftX += shiftSpeedX;
			shiftY += shiftSpeedY;
			
			shiftSpeedX = shiftSpeedX * 0.9;
			shiftSpeedY = shiftSpeedY * 0.9;
			
			currentTileImage.x = (shiftX % cellW) + Math.floor( ( mouseX - shiftX % cellW ) / cellW ) * cellW;
			currentTileImage.y = (shiftY % cellH) + Math.floor( ( mouseY - shiftY % cellH ) / cellH ) * cellH;
			
			fpsTF.text = FPSCounter.update();
		}
		
		private function processKeyEvents( e : KeyboardEvent ):void
		{
			switch ( e.keyCode )
			{
				case Keyboard.NUMBER_1 : curTexName = floorTextures[0]; break;
				case Keyboard.NUMBER_2 : curTexName = wallTextures[0];  break;
				case Keyboard.NUMBER_3 : curTexName = wallTextures[1];  break;
				case Keyboard.ENTER : 
					if ( inputMode )
					{
						inputMode = false;
						//process command
						if ( commandTF.text == "copy" )
							saveLevel();
						commandTF.text = "Press Enter for command";
					}
					else
					{
						inputMode = true;
						commandTF.text = "";
					}
				break;
			}
			
			if ( e.keyCode == Keyboard.BACKSPACE )
				commandTF.text = commandTF.text.slice( 0, commandTF.text.length - 1 );
				
			if ( inputMode && (e.charCode > 0) && (e.charCode != 8) && (e.charCode != 13) )
				commandTF.text += String.fromCharCode( e.charCode );
			
			currentTileImage.texture = AssetStorage.mapAtlas.getTexture( curTexName );
		}
		
		private function onMouseMove( e:TouchEvent ):void
		{
			var currentTouch : Touch = e.getTouch( stage, TouchPhase.BEGAN );
			if ( currentTouch ) //just clicked it
			{
				mouseDist = 0; //clear moving counter
			}
			
			currentTouch = e.getTouch( stage, TouchPhase.MOVED );
			if ( currentTouch ) //moving it
			{
				//set speed
				shiftSpeedX = currentTouch.globalX - currentTouch.previousGlobalX;
				shiftSpeedY = currentTouch.globalY - currentTouch.previousGlobalY;
				mouseDist += shiftSpeedX + shiftSpeedY; //mouse moves!
				
				if ( Keyboarder.instance.isKeyPressed( Keyboard.Z ) || Keyboarder.instance.isKeyPressed( Keyboard.X ) )
					shiftSpeedX = shiftSpeedY = 0;
					
				addTile();
			}
			
			if ( e.touches.length > 0 ) //if we have at least 1 touch
			{
				mouseX = e.touches[0].globalX;
				mouseY = e.touches[0].globalY;
			}
			
			currentTouch = e.getTouch( stage, TouchPhase.ENDED );
			if ( currentTouch ) //Mouse (finger?!? O_o) released
			{
				addTile();
				if ( mouseDist <3 &&  //so i love mouseDist var, as u can see
					 mouseDist >-3 )  //haha assface
				{
					//trace("TAP!");
				}
			}
		}
		
		private function addTile():void
		{
			var hittedObject : MapTile = objectsContainer.hitTest( new Point( currentTileImage.x - shiftX + 16, currentTileImage.y - shiftY + 16 ) ) as MapTile;
					
			if ( !hittedObject && Keyboarder.instance.isKeyPressed( Keyboard.Z ) )
			{
				var newTile : FloorMapTile = new FloorMapTile( AssetStorage.mapAtlas.getTexture( curTexName ) );
				newTile.x = currentTileImage.x - shiftX;
				newTile.y = currentTileImage.y - shiftY;
				objectsContainer.addChild( newTile );
			}
			if ( hittedObject && Keyboarder.instance.isKeyPressed( Keyboard.X ) )
				hittedObject.removeFromParent( true );
		}
		
		private function saveLevel():void
		{
			var str:String = "";
			for ( var i:int = 0; i < objectsContainer.numChildren; i++ )
				str += getQualifiedClassName( objectsContainer.getChildAt( i ) ) + "\n";
			Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, str );
		}
		
	}

}