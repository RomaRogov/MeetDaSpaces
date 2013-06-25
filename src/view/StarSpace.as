package view
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.filters.BlurFilter;
	
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class StarSpace extends Sprite 
	{
		private var _stars : Vector.<Image>;
		private var _width : int;
		private var _height : int;
		
		private static var _instance : StarSpace;
		
		public function StarSpace( count : uint, width : int, height : int )
		{
			_width = width;
			_height = height;
			
			_stars = new Vector.<Image>();
			for ( var i : int = 0; i < count; i++ )
			{
				var newStar : Image = new Image( AssetStorage.mainAtlas.getTexture("star") );
				newStar.x = Math.random() * _width;
				newStar.y = Math.random() * _height;
				newStar.scaleX = newStar.scaleY = Math.random() * 2;
				_stars.push( newStar );
				addChild( newStar );
			}
		}
		
		public function setSize( width : Number, height : Number ):void
		{
			_width = width;
			_height = _height;
			for each ( var star : Image in _stars )
			{
				star.x = Math.random() * _width;
				star.y = Math.random() * _height;
			}
		}
		
		public function moveStars( hor : Number, ver : Number ):void
		{
			for each ( var star : Image in _stars )
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
		
		public static function init( count : uint, width : Number, height : Number ):StarSpace
		{
			return _instance = new StarSpace( count, width, height );
		}
	}

}