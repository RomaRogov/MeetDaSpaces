package  
{
	import com.greensock.loading.XMLLoader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	/**
	 * ...
	 * @author qwfd
	 */
	public class AssetStorage extends EventDispatcher
	{
		//Font import
		[Embed(source="../fonts/PressStart2P.ttf", embedAsCFF="false", fontFamily="PressStart2P")]
        public static const UbuntuRegular:Class;
		
		private static var mainAtlas : TextureAtlas;
		private static var levelAtlas : TextureAtlas;
		private var assetList : Vector.<Object> = new Vector.<Object>; //(for sounds and stuff..)?
		
		public function AssetStorage() 
		{
			/*var loader : URLLoader = new URLLoader( new URLRequest( "assets/fileList.xml" ) );
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var xml : XML = new XML(e.target.data);
				for each ( var asset : XML in xml.texture )
					assetList.push( { name : asset.attribute("name"), file : asset.attribute("file") } );
				loadNext();
			} );*/
			
			//Loading main atlas
			loadImage( "assets/mainAtlas.png", "mainAtlas",  );
		}
		
		private function loadNext():void
		{
			if ( assetList.length == 0 )
			{
				trace("complete! ^^");
				dispatchEvent( new Event( Event.COMPLETE ) );
				return;
			}
			var currentAssetData : Object = assetList.shift();
			trace( "loading " + currentAssetData.name + "..." );
			loadImage( "assets/" + currentAssetData.file, currentAssetData.name, loadNext );
		}
		
		/* LOADS IMAGE AND RETURNS CALLBACK WITH BITMAP */
		private function loadImage( path:String, name: String, callback : Function ):void
		{
			var loader : Loader = new Loader();
			loader.load( new URLRequest( path ) );
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, 
				function OnComplete( e:Event ):void
				{
					//textures[name] = Texture.fromBitmapData( (e.target.content as Bitmap).bitmapData, false );
					callback( e.target.content as Bitmap );
				} );
		}
		
		public static function getTexture( name : String ):Texture
		{
			return textures[name];
		}
		
	}

}