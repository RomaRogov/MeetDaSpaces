package 
{
	import com.greensock.plugins.Positions2DPlugin;
	import de.exitgames.photon_as3.events.JoinEvent;
	import de.exitgames.photon_as3.events.LeaveEvent;
	import de.exitgames.photon_as3.loadBalancing.LoadBalancedPeer;
	import de.exitgames.photon_as3.loadBalancing.model.constants.Constants;
	import de.exitgames.photon_as3.loadBalancing.model.event.GameListEvent;
	import de.exitgames.photon_as3.loadBalancing.model.event.LoadBalancingStateEvent;
	import de.exitgames.photon_as3.loadBalancing.model.vo.ActorProperties;
	import de.exitgames.photon_as3.loadBalancing.model.vo.GameListEntry;
	import de.exitgames.photon_as3.loadBalancing.model.vo.GameProperties;
	import de.exitgames.photon_as3.PhotonCore;
	import de.exitgames.photon_as3.response.InitializeConnectionResponse;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import model.ChatEvent;
	import model.MoveEvent;
	import model.PushEvent;
	import model.Room;
	import starling.display.Image;
	import view.FlyingMessage;
	import view.Level;
	import view.StarlingScreens;
	import view.Player;
	import view.StarSpace;
	
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class Main extends Sprite 
	{
		private var _player : Player;
		private var _login : String;
		private var _bodyColor : uint;
		private var _faceColor : uint;
		private var _songPlayer : SongPlayer;
		private var _chat : ChatInterface;
		private var _level : Level;
		private var _room : Room;
		
		public function Main( login : String, bodyColor : uint, faceColor : uint ):void 
		{
			_login = login;
			_bodyColor = bodyColor;
			_faceColor = faceColor;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			//Waiting for room list...
			PhotonPeer.getInstance().addEventListener( GameListEvent.TYPE, onGameList );
		}
		
		private function init(e:Event = null):void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//Create player
			_player = new Player( true, _login )
			_player.faceColor = _faceColor;
			_player.bodyColor = _bodyColor;
			
			//Create level
			_level = new Level( "e1m1", _player );
			StarlingScreens.SetScreen( _level );
			
			//And interfaces at top
			_chat = new ChatInterface();
			_chat.playerCountTF.text = "Дохуя народу, впринципе";
			_chat.chatView.chatTF.htmlText = "";
			_chat.messageTF.text = "";
			_chat.scaleX = _chat.scaleY = 1.5;
			_chat.y = stage.stageHeight;
			addChild( _chat );
			
			_songPlayer = new SongPlayer( SongPlayerInterface(addChild( new SongPlayerInterface() )) );
			
			addEventListener( Event.ENTER_FRAME, onFrame );
			stage.addEventListener( Event.RESIZE, onResize );
		}
		
		private function onResize( e:* ):void
		{
			//_chat.scaleX = _chat.scaleY = (stage.stageWidth / _chat.width);
			_chat.y = stage.stageHeight;
			
			StarSpace.instance.setSize( stage.stageWidth, stage.stageHeight );
		}
		
		private function onFrame( e:* ):void
		{
			if ( !stage )
				return;
			
			//Send chat message
			if ( Keyboarder.instance.isKeyPressed( Keyboard.ENTER ) && _chat.messageTF.text != "" )
			{
				if ( _chat.messageTF.text.indexOf( "load" ) > -1 )
				{
					var roomNam : String = _chat.messageTF.text.split(" ")[1];
					_level.loadLevel( roomNam );
					//setNewRoom( roomNam );
					_chat.messageTF.text = "";
					return;
				}
				_room.sendChatMessage( _chat.messageTF.text );
				
				//View side
				addChatLine( _player.bodyColor, 0xFFFFFF, _player.playerName, _chat.messageTF.text );
				_player.parseEmotion( _chat.messageTF.text );
				//TODO: Flying message
				/*var pos : Point = _level.globalToLocal( localToGlobal( new Point( _player.x + 16, _player.y - 48 ) ) )
				new FlyingMessage( pos.x, pos.y, _player.playerName + ": " + _chat.messageTF.text, _level );*/
				FlyingMessage.show( _player.playerX, _player.playerY - 48, _player.playerName + ": " + _chat.messageTF.text, _level.layerPlayer );
				_chat.messageTF.text = "";
			}
		}
		
		private function addChatLine( nameColor : uint, messageColor : uint, name : String, message : String ):void
		{
			var currentTextPos : int = _chat.chatView.chatTF.length;
			_chat.chatView.chatTF.appendText( "\n" + name + ": " + message );
			var coloredFormat : TextFormat = _chat.chatView.chatTF.defaultTextFormat;
			coloredFormat.color = nameColor;
			_chat.chatView.chatTF.setTextFormat( coloredFormat, currentTextPos, currentTextPos + name.length + 1 );
			coloredFormat.color = messageColor;
			_chat.chatView.chatTF.setTextFormat( coloredFormat, currentTextPos + name.length + 1, _chat.chatView.chatTF.length );
			_chat.chatView.chatTF.scrollV = _chat.chatView.chatTF.maxScrollV;
		}
		
		private function applyChatMessage( e : ChatEvent ):void
		{
			addChatLine( e.color, 0xFFFFFF, e.nickName, e.message );
			
			var channel : SoundChannel = (new ChatMessageSound()).play();
			/*var vol : Number = 1.0 - (new Point( _player.playerX, _player.playerY ).subtract( new Point( currentPlayer.x, currentPlayer.y ) ).length / 1000);
			if ( vol < 0 )
				vol = 0;
			if ( channel )
				channel.soundTransform = new SoundTransform( vol, 0 );*/
		}
		
		//Someone entering event
		private function playerEntered( e : JoinEvent ):void
		{
			(new PlayerEnterSound()).play();
			if ( e.getActorNo() != PhotonPeer.getInstance().getActorNo() )
				addChatLine( 0x00FF00, 0xFFFF00, "System", "К нам заявился некий " + PhotonPeer.getInstance().getActorPropertiesByActorNo(e.getActorNo()).actorName + "." );
		}
		
		//Someone leaving event
		private function playerLeaved( e : LeaveEvent ):void
		{
			(new PlayerLeaveSound()).play();
			addChatLine( 0x00FF00, 0xFFFF00, "System", "К сожалению, " + PhotonPeer.getInstance().getActorPropertiesByActorNo(e.getActorNo()).actorName + " покинул нас." );
		}
		
		//We have list of rooms!
		private function onGameList( e : GameListEvent ):void
		{
			if ( _room == null ) //Joining at first time
			{
				PhotonPeer.getInstance().addEventListener( ChatEvent.TYPE, applyChatMessage );
				PhotonPeer.getInstance().addEventListener( JoinEvent.TYPE, playerEntered );
				PhotonPeer.getInstance().addEventListener( LeaveEvent.TYPE, playerLeaved );
			}
			else
			{
				_room.deinit();
			}
			joinRoomWithName( _level.curLevel );
			_room = new Room( _level, _player );
			
		}
		
		private function joinRoomWithName( roomName : String ):void
		{
			var list:Vector.<GameListEntry> = PhotonPeer.getInstance().getGameList();
			trace("So, we are connected and got game list (" + PhotonPeer.getInstance().getNumberOfGames() + " entries):" );
			
			var roomExists : Boolean = false;
			for each ( var game : GameListEntry in list )
				if ( game.roomName == roomName )
					roomExists = true;
			
			if ( roomExists )
			{
				//Room exists, create model
				trace( "joining exists room" );
				PhotonPeer.getInstance().opJoinGame( roomName );
			}
			else
			{
				//Room don't exists, create room with level name
				var gp:GameProperties = GameProperties.createDefault();
				gp.customProperties = new Dictionary();
				//gp.customProperties["starHolderId"] = _player.name;
				
				PhotonPeer.getInstance().opCreateGame( roomName, gp );
			}
		}
		
		private function setNewRoom( roomName : String ):void
		{
			//PhotonPeer.getInstance().opLeaveGame();
			//_room.deinit();
			//joinRoomWithName( roomName );
			//_room = new Room( _level, _player );
		}
	}
	
}