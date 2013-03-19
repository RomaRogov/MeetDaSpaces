package editor 
{
	import editor.tiles.FloorMapTile;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.Keyboard;
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
		
		public function Editor() 
		{
			addEventListener( Event.ADDED_TO_STAGE, function(e:*):void {
				var assetStorage : AssetStorage = new AssetStorage();
				assetStorage.addEventListener( Event.COMPLETE, onStage );
				} );
		}
		
		private function onStage( e:* ):void
		{
			//floorTexture = AssetStorage.getTexture( "floor" );
			
			var tileAtlasImage : Image = new Image( AssetStorage.mainAtlas.getTexture( "editor_tile" ) );
			
			var tileTexture : RenderTexture = new RenderTexture( 32, 32 );
			tileTexture.draw( tileAtlasImage );
			tileTexture.repeat = true;
			backTileImage = new Image( tileTexture );
			backTileImage.width = Math.ceil( stage.stageWidth / 32 ) * 32;
			backTileImage.height = Math.ceil( stage.stageHeight / 32 ) * 32;
			addChild( backTileImage );
			
			
			currentTileImage = new Image( AssetStorage.mapAtlas.getTexture( curTexName ) );
			currentTileImage.alpha = 0.5;
			addChild( currentTileImage );
			
			stage.addEventListener( TouchEvent.TOUCH, onMouseMove );
			
			addChild( objectsContainer = new Sprite() );
			
			fpsTF = new TextField( 200, 30, "--.- FPS", "PressStart2P", 12, 0xFFFFFF );
			fpsTF.hAlign = "left";
			addChild( fpsTF );
			
			addEventListener( Event.ENTER_FRAME, onFrame );
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
			
			if ( Keyboarder.instance.isKeyPressed( Keyboard.NUMBER_1 ) )
				curTexName = "floor";
			if ( Keyboarder.instance.isKeyPressed( Keyboard.NUMBER_2 ) )
				curTexName = "wall";
			if ( Keyboarder.instance.isKeyPressed( Keyboard.NUMBER_3 ) )
				curTexName = "wall_end";
		}
		
		private function changeImage():void
		{
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
		
	}

}