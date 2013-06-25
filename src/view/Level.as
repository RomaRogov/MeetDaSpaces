package view 
{
	import editor.MapTile;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import model.LevelColliders;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.BlurFilter;
	
	/**
	 * Level with blocks and so
	 * @author bL00RiSe
	 */
	public class Level extends Sprite 
	{
		public static var resourcesReady : Boolean = false;
		public var curLevel : String;
		
		private var layerBack   : Sprite;
		private var layerMiddle : Sprite;
		private var layerFront  : Sprite;
		public var layerPlayer : Sprite;
		
		private var localPlayer : Player;
		
		private var spawnPoints : Vector.<Point>;
		
		public function Level( levelName : String, player : Player ) 
		{
			curLevel = levelName;
			addEventListener( starling.events.Event.ADDED_TO_STAGE, Init );
			
			localPlayer = player;
		}
		
		private function Init():void
		{
			addChild( StarSpace.init( 100, stage.stageWidth, stage.stageHeight ) );
			
			//Layers for level
			addChild( layerBack   = new Sprite() );
			addChild( layerMiddle = new Sprite() );
			addChild( layerPlayer = new Sprite() );
			addChild( layerFront  = new Sprite() );
			layerBack.name = "back";
			layerMiddle.name = "middle";
			layerFront.name = "front";
			
			layerPlayer.addChild( localPlayer );
			
			loadLevel( curLevel );
			
			addEventListener( starling.events.Event.ENTER_FRAME, onFrame );
		}
		
		private function onFrame( e:* ):void
		{
			layerBack.x = layerMiddle.x = layerFront.x = layerPlayer.x = Math.round( stage.stageWidth/2 - localPlayer.playerX );
			layerBack.y = layerMiddle.y = layerFront.y = layerPlayer.y = Math.round( stage.stageHeight/2 - localPlayer.playerY );
			//pivotX = -Math.round( stage.stageWidth  / 2 - localPlayer.playerX );
			//pivotY = -Math.round( stage.stageHeight / 2 - localPlayer.playerY );
			
			//We are flying at space, yeah?
			StarSpace.instance.moveStars( 1, 0 );
		}
		
		public function addPlayer( player : Player ):void
		{
			layerPlayer.addChild( player );
		}
		
		public function loadLevel( levelName : String ):void
		{
			localPlayer.active = false;
			curLevel = levelName;
			clearLevel();
			AssetStorage.loadLevelAtlas( curLevel, function():void 
				{
					var loader : URLLoader = new URLLoader( new URLRequest( curLevel +  "/level.txt" ) );
					loader.addEventListener( flash.events.Event.COMPLETE, parseLevel );
				} );
		}
		
		private function parseLevel( e : flash.events.Event ):void
		{
			//Parse level data and create objects
			var level : Object = JSON.parse( String( e.target.data ) );
			
			fillLayer( level.back, layerBack );
			fillLayer( level.middle, layerMiddle );
			fillLayer( level.front, layerFront );
			
			LevelColliders.refreshColliders( level );
			LevelColliders.spawnPoints = spawnPoints;
			
			localPlayer.relativePos = LevelColliders.getRandomSpawn();
			localPlayer.active = true;
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
				
				if ( String(tile.img).indexOf("spawn") > -1 )
					spawnPoints.push( new Point( tile.x+16, tile.y+16 ) );
			}
		}
		
		private function clearLevel():void
		{
			spawnPoints = new Vector.<Point>();
			//Clear current level
			var removeList : Vector.<DisplayObject> = new Vector.<DisplayObject>();
			for ( var i:int = 0; i < layerBack.numChildren; i++ )
				removeList.push( layerBack.getChildAt( i ) );
			for ( i = 0; i < layerMiddle.numChildren; i++ )
				removeList.push( layerMiddle.getChildAt( i ) );
			for ( i = 0; i < layerPlayer.numChildren; i++ )
				if ( !Player(layerPlayer.getChildAt( i )).isLocal )
					removeList.push( layerPlayer.getChildAt( i ) );
			for ( i = 0; i < layerFront.numChildren; i++ )
				removeList.push( layerFront.getChildAt( i ) );
				
			for each ( var child : DisplayObject in removeList )
				child.removeFromParent( true );
		}

	}

}