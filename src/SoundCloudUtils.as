package  
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	/**
	 * ...
	 * @author ...
	 */
	public class SoundCloudUtils 
	{
		public static const CLIENT_ID : String = "5c822270d56a428b7b4c4f37833d404d";
		
		/**
		 * Sending request and returning array of track's data in callback
		 * @param   username User id from SoundCloud
		 * @param	callback function( tracks : Array of Object with data )
		 */
		public static function GetTracks( username : String, callback : Function, onlyStreamable : Boolean = false ):void
		{
			var SCRequest : URLRequest = new URLRequest( "http://api.soundcloud.com/users/" + username + "/tracks.json" );
			SCRequest.method = "GET";
			SCRequest.data = new URLVariables( "client_id=" + CLIENT_ID );
			
			var SCLoader : URLLoader = new URLLoader();
			SCLoader.addEventListener( Event.COMPLETE,
			function( e : Event ):void 
			{
				var result : Array = JSON.parse(URLLoader(e.target).data) as Array;
				if ( onlyStreamable )
					for ( var i : int = 0; i < result.length; i++ )
						if ( !result[i].stream_url )
							result.splice( i, 1 );
				callback( result ); 
			} );
			SCLoader.dataFormat = URLLoaderDataFormat.TEXT;
			SCLoader.load( SCRequest );
		}
		
		
		public static function GetSound( trackData : Object ):Sound
		{
			var SCRequest : URLRequest = new URLRequest( trackData.stream_url + ".json" );
			SCRequest.method = "GET";
			SCRequest.data = new URLVariables( "client_id=" + CLIENT_ID );
			
			var sound : Sound = new Sound( SCRequest );
			return sound;
		}
	}

}