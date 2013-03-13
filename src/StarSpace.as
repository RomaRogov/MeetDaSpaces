package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class StarSpace extends MovieClip 
	{
		private var _stars : Vector.<Star>;
		private var _width : int;
		private var _height : int;
		
		private static var _instance : StarSpace;
		
		public function StarSpace( count : uint, width : int, height : int )
		{
			_width = width;
			_height = height;
			
			_stars = new Vector.<Star>();
			for ( var i : int = 0; i < count; i++ )
			{
				var newStar : Star = new Star();
				newStar.x = Math.random() * _width;
				newStar.y = Math.random() * _height;
				newStar.scaleX = newStar.scaleY = Math.random() * 2;
				_stars.push( newStar );
				addChild( newStar );
			}
			
			_instance = this;
		}
		
		public function moveStars( hor : Number, ver : Number ):void
		{
			for each ( var star : Star in _stars )
			{
				star.x -= hor * star.scaleX / 10;
				star.y -= ver * star.scaleY / 10;
				
				if ( star.x > (_width + star.width/2) )
					star.x = -star.width / 2;
				if ( star.x < (-star.width/2) )
					star.x = _width + star.width / 2;
				if ( star.y > (_height + star.height/2) )
					star.y = -star.height / 2;
				if ( star.y < -star.height/2 )
					star.y =  _height + star.height / 2;
			}
		}
		
		public static function get instance():StarSpace
		{
			if ( !_instance )
				trace("Trying to get StarSpace before creation!!");
			return _instance;
		}
	}

}