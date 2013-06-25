package editor 
{
	import flash.display.BitmapData;
	import starling.display.Image;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author qwfd
	 */
	public class MapTile extends Image
	{
		public var type : String = "floor";
		public var texName : String;
		
		public function MapTile( tex : Texture ) 
		{
			name = "maptile";
			super( tex );
		}
		
	}

}