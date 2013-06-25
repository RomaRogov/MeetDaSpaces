package  view
{
	import flash.display.BitmapData;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.VAlign;
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class FlyingMessage extends Sprite
	{
		
		public function FlyingMessage( message : String )
		{
			
			
			/*_interface = new FlyingMessageInterface();
			_interface.x = x;
			_interface.y = y;
			_interface.messageTF.text = message;
			_interface.messageTF.x = -_interface.messageTF.width / 2;
			_interface.messageTF.y = -_interface.messageTF.textHeight / 2;
			_interface.back.width = _interface.messageTF.textWidth + 5;
			_interface.back.height = _interface.messageTF.textHeight + 5;
			
			_parent.addChild( _interface );*/
			
			var text : TextField = new TextField( 200, 100, message, "PressStart2P", 8, 0x000000 );
			text.border = true;
			text.vAlign = VAlign.TOP;
			text.width = text.textBounds.width;
			text.height = text.textBounds.height + 5;
			
			addChild( new Image( Texture.fromBitmapData( new BitmapData( text.width, text.height, false, 0xFFFFFF ) ) ) );
			addChild( text );
			
			addEventListener( Event.ENTER_FRAME, onFrame );
		}
		
		private function onFrame( e:* ):void
		{
			y -= .3;
			alpha -= 0.005;
			if ( alpha <= 0 )
			{
				removeEventListener( Event.ENTER_FRAME, onFrame );
				removeFromParent( true );
			}
		}
		
		public static function show( x : Number, y : Number, message : String, parent : Sprite ):void
		{
			var msg : FlyingMessage = new FlyingMessage( message );
			parent.addChild( msg );
			msg.x = x - msg.width/2;
			msg.y = y;
		}
		
	}

}