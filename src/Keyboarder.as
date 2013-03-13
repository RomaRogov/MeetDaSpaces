package  
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class Keyboarder extends EventDispatcher
	{
		private static var _instance : Keyboarder;
		
		private var _pressedKeys : Object;
		private var _stage       : Stage;
		
		public static function get instance():Keyboarder { 
			if ( !_instance )
				_instance = new Keyboarder();
			return _instance;
		}
		
		public function Keyboarder() 
		{ 
			_pressedKeys = new Object();
		}
		
		public function set stage( value : Stage ):void {
			if ( !_stage )
			{
				value.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
				value.addEventListener( KeyboardEvent.KEY_UP  , onKeyUp   );
			}
			_stage = value;
		}
		
		private function onKeyDown( e : KeyboardEvent ):void {
			_pressedKeys[e.keyCode] = true;
			dispatchEvent( e );
		}
		
		private function onKeyUp( e : KeyboardEvent ):void {
			_pressedKeys[e.keyCode] = false;
			dispatchEvent( e );
		}
		
		public function isKeyPressed( keyCode : int ):Boolean {
			return _pressedKeys[keyCode];
		}
		
	}

}