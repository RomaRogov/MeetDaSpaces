package  
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
		private static var _container : MovieClip;
		
		public static function refreshColliders( container : MovieClip ):void
		{
			_blocks = new Vector.<Rectangle>();
			_floors = new Vector.<Rectangle>();
			_container = container;
			for ( var i:int = 0; i < container.numChildren; i++ )
			{
				switch ( getQualifiedClassName(container.getChildAt(i)) )
				{
					case "MapBlock" : _blocks.push( container.getChildAt(i).getRect( container ) ); break;
					case "MapFloor" : _floors.push( container.getChildAt(i).getRect( container ) ); break;
				}
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
		
		public static function getContainer():MovieClip { return _container; }
		
	}

}