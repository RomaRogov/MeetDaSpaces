package  
{
	import com.greensock.loading.data.VideoLoaderVars;
	import com.greensock.loading.XMLLoader;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.FileFilter;
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
		
		public static var mainAtlas : TextureAtlas;
		public static var mapAtlas : TextureAtlas;
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
			loadAtlas( "assets/mainAtlas.xml", 
				function( atlas : TextureAtlas ):void 
				{
					trace("main atlas loaded!");
					mainAtlas = atlas;
					loadAtlas( "e1m1/mapAtlas.xml", 
						function( atlas : TextureAtlas ):void 
						{
							trace("map atlas loaded!");
							mapAtlas = atlas;
							dispatchEvent( new Event( Event.COMPLETE ) );
						} );
				} );
		}
		
		//Loads XML and image and returns callback with TextureAtlas
		private function loadAtlas( path : String, callback : Function ):void
		{
			var folderPath : String = path.slice( 0, path.lastIndexOf("/") + 1 );
			var loader : URLLoader = new URLLoader( new URLRequest( path ) );
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				var xml : XML = new XML(e.target.data);
				loadImage( folderPath + xml.attribute( "imagePath" ), 
					function( img : Bitmap ):void
					{
						var tex : Texture = Texture.fromBitmap( img, false );
						callback( new TextureAtlas( tex, xml ) );
					} );
			} );
		}
		
		private function loadNext():void
		{
			if ( assetList.length == 0 )
			{
				trace("complete! ^^");
				
				return;
			}
			var currentAssetData : Object = assetList.shift();
			trace( "loading " + currentAssetData.name + "..." );
			loadImage( "assets/" + currentAssetData.file,  loadNext );
		}
		
		/* LOADS IMAGE AND RETURNS CALLBACK WITH BITMAP */
		private function loadImage( path:String, callback : Function ):void
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
		
	}

}