package  
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class FlyingMessage 
	{
		public var _interface : FlyingMessageInterface;
		public var _parent : Sprite;
		
		public function FlyingMessage( x : Number, y:Number, message : String, parent : Sprite )
		{
			_parent = parent;
			
			_interface = new FlyingMessageInterface();
			_interface.x = x;
			_interface.y = y;
			_interface.messageTF.text = message;
			_interface.messageTF.x = -_interface.messageTF.width / 2;
			_interface.messageTF.y = -_interface.messageTF.textHeight / 2;
			_interface.back.width = _interface.messageTF.textWidth + 5;
			_interface.back.height = _interface.messageTF.textHeight + 5;
			
			_parent.addChild( _interface );
			_interface.addEventListener( Event.ENTER_FRAME, onFrame );
		}
		
		private function onFrame( e:* ):void
		{
			_interface.y -= .3;
			_interface.alpha -= 0.0005;
			if ( _interface.alpha <= 0 )
			{
				_interface.removeEventListener( Event.ENTER_FRAME, onFrame );
				_parent.removeChild( _interface );
			}
		}
		
	}

}