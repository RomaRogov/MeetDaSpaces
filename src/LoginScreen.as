package  
{
	import com.greensock.plugins.Positions2DPlugin;
	import de.exitgames.photon_as3.loadBalancing.LoadBalancedPeer;
	import de.exitgames.photon_as3.loadBalancing.model.event.LoadBalancingStateEvent;
	import editor.Editor;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.net.navigateToURL;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.getTimer;
	import starling.core.Starling;
	import util.FPSCounter;
	import view.StarlingScreens;
	/**
	 * ...
	 * @author qwfd
	 */
	public class LoginScreen extends Sprite
	{
		private var _interface : LoginInterface;
		private var _bodyColor : uint;
		private var _faceColor : uint;
		
		private var _starling : Starling;
		
		public function LoginScreen() 
		{
			_interface = new LoginInterface();
			addChild( _interface );
			
			_interface.loginField.text = "";
			_interface.loginBtn["textTF"].text = "Космос";
			_interface.vkBtn["textTF"].text = "ВКонтакте";
			_interface.editBtn["textTF"].text = "Захуярить";
			_interface.colorBtn["textTF"].text = "Сменить цвет";
			_interface.player.nameTF.text = "Введите логин";
			//_interface.player.face.gotoAndStop(0);
			_interface.vkBtn.addEventListener( MouseEvent.CLICK, function(e:*):void { navigateToURL( new URLRequest("http://vk.com/zoyge"), "_blank" ); } );
			_interface.editBtn.addEventListener( MouseEvent.CLICK, enterEditor );
			_interface.colorBtn.addEventListener( MouseEvent.CLICK, regenColor );
			_interface.loginField.addEventListener( TextEvent.TEXT_INPUT, nickChanged );
			
			bodyColor = Math.random() * 0xFFFFFF;
			faceColor = Math.random() * 0xFFFFFF;
			
			_interface.bodyColor.text = Utils.colorToHEX( _bodyColor );
			_interface.faceColor.text = Utils.colorToHEX( _faceColor );
			
			_interface.bodyColor.addEventListener( TextEvent.TEXT_INPUT, bodyColorChanged );
			_interface.faceColor.addEventListener( TextEvent.TEXT_INPUT, faceColorChanged );
			
			Utils.serverLog( "Someone opened the game" );
			
			//Init starling
			addEventListener( Event.ADDED_TO_STAGE, function(e:*):void { 
				Keyboarder.instance.stage = stage;
				StarlingScreens.Init( stage );
				AssetStorage.Init( function():void { _interface.loginBtn.addEventListener( MouseEvent.CLICK, onLogin ); } );
				} );
		}
		
		private function bodyColorChanged( e: TextEvent ):void
		{
			var color : Number = parseInt( _interface.bodyColor.text + e.text, 16 );
			if ( !isNaN( color ) )
				bodyColor = color;
		}
		
		private function faceColorChanged( e: TextEvent ):void
		{
			var color : Number = parseInt( _interface.faceColor.text + e.text, 16 );
			if ( !isNaN( color ) )
				faceColor = color;
		}
		
		private function onLogin( e:* ):void
		{
			if ( _interface.loginField.text == "" )
				return;
				
			_interface.loginBtn.removeEventListener( MouseEvent.CLICK, onLogin );
			_interface.loginBtn["textTF"].text = "Подключение...";
			
			//Init PhotonCloud connection
			var peer : LoadBalancedPeer = PhotonPeer.getInstance();
			peer.showDetailedTraceInfos(false);
			peer.setMirrorCustomEvents(false);
			
            var server:String = "app.exitgamescloud.com";
            var port:int = 4530;
            var policyPort:int = 843;
            var applicationId:String = "3b492b1f-05ac-4abb-9bb6-ac2dd0bc58d4";
            var applicationVersion:String = "v1.0";
			
			peer.establishBalancedConnection(server, port, policyPort, applicationId, applicationVersion);
			
			peer.addEventListener(LoadBalancingStateEvent.CONNECTED_TO_MASTER, onConnectionSuccess );
		}
		
		private function enterEditor( e : * ):void
		{
			removeChild( _interface );
			
			_interface.editBtn["textTF"].text = "Ща, погодь...";
			StarlingScreens.SetScreen( new Editor() );
		}
		
		private function nickChanged( e : TextEvent ):void
		{
			_interface.player.nameTF.text = e.currentTarget.text + e.text;
		}
		
		private function onConnectionSuccess( e:* ):void
		{
			var gameCycle : Main = new Main( _interface.loginField.text, _bodyColor, _faceColor );
			removeChild( _interface );
			addChild( gameCycle );
		}
		
		public function regenColor( e:* ):void
		{
			bodyColor = Math.random() * 0xFFFFFF;
			faceColor = Math.random() * 0xFFFFFF;
			
			_interface.bodyColor.text = Utils.colorToHEX( _bodyColor );
			_interface.faceColor.text = Utils.colorToHEX( _faceColor );
		}
		
		public function set bodyColor( val : uint ):void
		{
			_bodyColor = val;
			//hex to rgb
			var bodyr:uint = ((val & 0xFF0000) >> 16);
			var bodyg:uint = ((val & 0x00FF00) >>  8);
			var bodyb:uint = ((val & 0x0000FF)      );
			//_interface.player.body.transform.colorTransform = new ColorTransform( 1, 1, 1, 1, -255 + bodyr, -255 + bodyg, -255 + bodyb );
		}
		public function get bodyColor():uint { return _bodyColor; }
		
		public function set faceColor( val : uint ):void
		{
			_faceColor = val;
			//hex to rgb
			var facer:uint = ((val & 0xFF0000) >> 16);
			var faceg:uint = ((val & 0x00FF00) >>  8);
			var faceb:uint = ((val & 0x0000FF)      );
			//_interface.player.face.transform.colorTransform = new ColorTransform( 1, 1, 1, 1, -255 + facer, -255 + faceg, -255 + faceb );
		}
	}

}