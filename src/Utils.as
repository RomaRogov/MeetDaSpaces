package  
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	/**
	 * ...
	 * @author qwfd
	 */
	public class Utils 
	{
		
		public static function colorToHEX( color : uint ):String
		{
			return (color.toString(16).toUpperCase());
		}
		
		public static function serverLog( msg : String ):void
		{
			var req : URLRequest = new URLRequest( "http://bl00r.fatal.ru/log/logger.php" );
			req.method = "POST";
			req.data = new URLVariables( "msg=" + msg );
			var loader : URLLoader = new URLLoader();
			loader.load( req );
		}
	}

}