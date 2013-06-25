package editor 
{
	import com.greensock.loading.core.DisplayObjectLoader;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import starling.display.DisplayObject;
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
		
		private var layerBack : Sprite; //under all
		private var layerMiddle : Sprite; //between back and player
		private var layerFront  : Sprite; //over all
		private var currentLayer : Sprite;
		
		private var TexList : Vector.<String> = new Vector.<String>();
		private var curTexIndex : int = 0;
		private var curLevel : String = "e1m1";
		
		private var fpsTF : TextField;
		private var commandTF : TextField;
		
		private var inputMode : Boolean = false;
		
		public static var instance : Editor;
		
		public function Editor() 
		{
			instance = this;
			addEventListener( Event.ADDED_TO_STAGE, Init );
		}
		
		private function Init():void
		{
			loadLevel( curLevel );
			
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
			//Layers for level
			addChild( layerBack   = new Sprite() );
			addChild( layerMiddle = new Sprite() );
			addChild( layerFront  = new Sprite() );
			layerBack.name = "back";
			layerMiddle.name = "middle";
			layerFront.name = "front";
			currentLayer = layerBack;
			//Preparing Image for current tile
			currentTileImage = new Image( AssetStorage.mainAtlas.getTexture("star") );
			currentTileImage.alpha = 0.5;
			addChild( currentTileImage );
			//FPS counter
			fpsTF = new TextField( 500, 30, "--.- FPS", "PressStart2P", 12, 0xFFFFFF );
			fpsTF.hAlign = "left";
			addChild( fpsTF );
			//Command TF
			commandTF = new TextField( stage.stageWidth, 30, "Press Enter for command", "PressStart2P", 12, 0xFFFFFF );
			commandTF.hAlign = "left";
			commandTF.x = 20;
			addChild( commandTF );
			
			//Listeners
			stage.addEventListener( TouchEvent.TOUCH, onMouseMove );
			addEventListener( Event.ENTER_FRAME, onFrame );
			addEventListener( Event.RESIZE, onResize );
			Keyboarder.instance.addEventListener( KeyboardEvent.KEY_DOWN, processKeyEvents );
		}
		
		private function onResize( e:* ):void
		{
			backTileImage.width = Math.ceil( stage.stageWidth / 32 ) * 32;
			backTileImage.height = Math.ceil( stage.stageHeight / 32 ) * 32;
		}
		
		private function onFrame( e:* ):void
		{
			if ( !backTileImage || !stage )
				return;

			/* SCROLL BACKROUND */
			var horRepeat : int = Math.ceil( stage.stageWidth  / cellW );
			var verRepeat : int = Math.ceil( stage.stageHeight / cellH );
			var horTextureShift : Number = (-Math.round(shiftX) % cellW) / cellW;
			var verTextureShift : Number = (-Math.round(shiftY) % cellH) / cellH;
			backTileImage.setTexCoords( 0, new Point(             horTextureShift,             verTextureShift ) );
			backTileImage.setTexCoords( 1, new Point( horTextureShift + horRepeat,             verTextureShift ) );
			backTileImage.setTexCoords( 2, new Point(             horTextureShift, verTextureShift + verRepeat ) );
			backTileImage.setTexCoords( 3, new Point( horTextureShift + horRepeat, verTextureShift + verRepeat ) );
			
			layerBack.x = layerMiddle.x = layerFront.x = Math.round( shiftX );
			layerBack.y = layerMiddle.y = layerFront.y = Math.round( shiftY );
			
			shiftX += shiftSpeedX;
			shiftY += shiftSpeedY;
			
			shiftSpeedX = shiftSpeedX * 0.9;
			shiftSpeedY = shiftSpeedY * 0.9;
			
			currentTileImage.x = (shiftX % cellW) + Math.floor( ( mouseX - shiftX % cellW ) / cellW ) * cellW;
			currentTileImage.y = (shiftY % cellH) + Math.floor( ( mouseY - shiftY % cellH ) / cellH ) * cellH;
			
			fpsTF.text = FPSCounter.update() + "\n" + curLevel + " | Layer: " + currentLayer.name;
			commandTF.y = stage.stageHeight - 30;
		}
		
		private function processKeyEvents( e : KeyboardEvent ):void
		{
			switch ( e.keyCode )
			{
				case Keyboard.A : curTexIndex = ( curTexIndex > 0 ) ? curTexIndex-1 : TexList.length-1; break; //prev sprite
				case Keyboard.S : curTexIndex = ( curTexIndex < (TexList.length - 1) ) ? curTexIndex + 1 : 0;  break; //next sprite
				case Keyboard.NUMBER_1 : currentLayer = layerBack; break; //back layer
				case Keyboard.NUMBER_2 : currentLayer = layerMiddle; break; //middle layer
				case Keyboard.NUMBER_3 : currentLayer = layerFront; break; //front layer
				case Keyboard.ENTER : 
					if ( inputMode )
					{
						inputMode = false;
						//process command
						if ( commandTF.text == "copy" )
							saveLevel();
						if ( commandTF.text.indexOf( "load" ) > -1 )
							loadLevel( commandTF.text.split(" ")[1] );
						if ( commandTF.text == "clear" )
							clearLevel();
						if ( commandTF.text == "zeropos" )
							shiftX = shiftY = 0;
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
			
			currentTileImage.texture = AssetStorage.mapAtlas.getTexture( TexList[curTexIndex] );
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
			var hittedObject : MapTile = currentLayer.hitTest( new Point( currentTileImage.x - shiftX + 16, currentTileImage.y - shiftY + 16 ) ) as MapTile;
					
			if ( !hittedObject && Keyboarder.instance.isKeyPressed( Keyboard.Z ) )
			{
				var newTile : MapTile = new MapTile( AssetStorage.mapAtlas.getTexture( TexList[curTexIndex] ) );
				newTile.x = currentTileImage.x - shiftX;
				newTile.y = currentTileImage.y - shiftY;
				newTile.texName = TexList[curTexIndex];
				currentLayer.addChild( newTile );
				newTile = null;
			}
			if ( hittedObject && Keyboarder.instance.isKeyPressed( Keyboard.X ) )
				hittedObject.removeFromParent( true );
		}
		
		private function saveLevel():void
		{
			//Back layer
			var str:String = "{ \"back\" : [\n";
			for ( var i:int = 0; i < layerBack.numChildren; i++ )
				str += "{ \"x\":"
						+ Math.round( layerBack.getChildAt( i ).x )+ ", \"y\":"
						+ Math.round( layerBack.getChildAt( i ).y )+ ", \"img\":\""
						+ MapTile(layerBack.getChildAt( i )).texName + "\" }"
						+ ((i==(layerBack.numChildren-1)) ? "\n" : ", \n");
			str += " ],\n";
			//Middle layer
			str += "\"middle\" : [\n";
			for ( i = 0; i < layerMiddle.numChildren; i++ )
				str += "{  \"x\":"
						+ Math.round( layerMiddle.getChildAt( i ).x )+ ", \"y\":"
						+ Math.round( layerMiddle.getChildAt( i ).y )+ ", \"img\":\""
						+ MapTile(layerMiddle.getChildAt( i )).texName + "\" }"
						+ ((i==(layerMiddle.numChildren-1)) ? "\n" : ", \n");
			str += " ],\n";
			//Front layer
			str += "\"front\" : [\n";
			for ( i = 0; i < layerFront.numChildren; i++ )
				str += "{  \"x\":"
						+ Math.round( layerFront.getChildAt( i ).x ) + ", \"y\":"
						+ Math.round( layerFront.getChildAt( i ).y )+ ", \"img\":\""
						+ MapTile(layerFront.getChildAt( i )).texName + "\" }"
						+ ((i==(layerFront.numChildren-1)) ? "\n" : ", \n");
			str += " ] }\n";
			Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, str );
		}
		
		private function loadLevel( levelName : String ):void
		{
			curLevel = levelName;
			AssetStorage.loadLevelAtlas( curLevel, function():void 
				{
					var loader : URLLoader = new URLLoader( new URLRequest( curLevel +  "/level.txt" ) );
					loader.addEventListener( Event.COMPLETE, parseLevel );
				} );
		}
		
		private function parseLevel( e : flash.events.Event ):void
		{
			clearLevel();
			
			//Parse level data and create objects
			var level : Object = JSON.parse( String( e.target.data ) );
			
			fillLayer( level.back, layerBack );
			fillLayer( level.middle, layerMiddle );
			fillLayer( level.front, layerFront );
			
			TexList = AssetStorage.mapAtlas.getNames();
			curTexIndex = 0;
			currentTileImage.texture = AssetStorage.mapAtlas.getTexture( TexList[curTexIndex] );
			currentTileImage.width = currentTileImage.texture.nativeWidth;
			currentTileImage.height = currentTileImage.texture.nativeHeight;
		}
		
		private function fillLayer( tiles : Array, layer : Sprite ):void
		{
			for each ( var tile : Object in tiles )
			{
				var newTile : MapTile = new MapTile( AssetStorage.mapAtlas.getTexture( tile.img ) );
				newTile.x = tile.x;
				newTile.y = tile.y;
				newTile.texName = tile.img;
				layer.addChild( newTile );
				newTile = null;
			}
		}
		
		private function clearLevel():void
		{
			//Clear current level
			var removeList : Vector.<DisplayObject> = new Vector.<DisplayObject>();
			for ( var i:int = 0; i < layerBack.numChildren; i++ )
				removeList.push( layerBack.getChildAt( i ) );
			for ( i = 0; i < layerMiddle.numChildren; i++ )
				removeList.push( layerMiddle.getChildAt( i ) );
			for ( i = 0; i < layerFront.numChildren; i++ )
				removeList.push( layerFront.getChildAt( i ) );
			for each ( var child : DisplayObject in removeList )
				child.removeFromParent( true );
		}
	}

}