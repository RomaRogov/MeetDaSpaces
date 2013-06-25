package model
{
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class LevelColliders 
	{
		
		private static var _blocks : Vector.<Rectangle>;
		private static var _floors : Vector.<Rectangle>;
		public static var spawnPoints : Vector.<Point>;
		
		public static function refreshColliders( tileData : Object ):void
		{
			_blocks = new Vector.<Rectangle>();
			_floors = new Vector.<Rectangle>();
			fillLayer( tileData.back );
			fillLayer( tileData.middle );
			fillLayer( tileData.front );
		}
		
		private static function fillLayer( tiles : Array ):void
		{
			for each ( var tile : Object in tiles )
			{
				if ( String(tile.img).indexOf("wall") > -1 )
					_blocks.push( new Rectangle( tile.x, tile.y, 32, 32 ) );
				if ( String(tile.img).indexOf("floor") > -1 )
					_floors.push( new Rectangle( tile.x, tile.y, 32, 32 ) );
			}
		}
		
		public static function checkBlockPoint( point : Point ):Boolean
		{
			for each ( var collider : Rectangle in _blocks )
				if ( collider.containsPoint( point ) )
					return true;
			return false;
		}
		
		public static function checkBlockRect( rect : Rectangle ):Boolean
		{
			for each ( var collider : Rectangle in _blocks )
				if ( collider.intersects( rect ) )
					return true;
			return false;
		}
		
		public static function checkFloorPoint( point : Point ):Boolean
		{
			for each ( var collider : Rectangle in _floors )
				if ( collider.containsPoint( point ) )
					return true;
			return false;
		}
		
		public static function checkFloorRect( rect : Rectangle ):Boolean
		{
			for each ( var collider : Rectangle in _floors )
				if ( collider.intersects( rect ) )
					return true;
			return false;
		}
		
		public static function getRandomSpawn():Point
		{
			var choice : int = Math.floor( Math.random() * spawnPoints.length );
			return spawnPoints[ choice ].clone();
		}
	}

}