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
		private var _players : Vector.<Player>;
		private var _starField : StarSpace;
		private var _level : Levels;
		private var _songPlayer : SongPlayer;
		private var _chat : ChatInterface;
		
		private var _peer : LoadBalancedPeer;
		
		public function Main( login : String, bodyColor : uint, faceColor : uint ):void 
		{
			_login = login;
			_bodyColor = bodyColor;
			_faceColor = faceColor;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
			_peer = PhotonPeer.getInstance();
			//We are connected. Next step - set listeners and get game list
			PhotonPeer.getInstance().addEventListener(GameListEvent.TYPE, onGameList );
			_peer.addEventListener( ChatEvent.TYPE, applyChatMessage );
			_peer.addEventListener( MoveEvent.TYPE, onPlayerMoved );
			_peer.addEventListener( PushEvent.TYPE, onPlayerPush );
			
			Utils.serverLog( _login + " entered the game!" );
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			//Create starfield
			_starField = new StarSpace( 60, stage.stageWidth, stage.stageHeight );
			_starField.x = _starField.y = 0;
			addChild( _starField );
			
			//Then - level
			_level = new Levels();
			addChild( _level );
			LevelColliders.refreshColliders( _level.blocks_level_1 );
			_level.removeChild( _level.blocks_level_1 );
			_level.level_1.cacheAsBitmap = true;
			
			//Player on level
			_player = new Player( true, _login );
			_player.x = stage.stageWidth / 2;
			_player.y = stage.stageHeight / 2;
			addChild( _player );
			
			//And interfaces at top
			_chat = new ChatInterface();
			_chat.playerCountTF.text = "Дохуя народу, впринципе";
			_chat.chatView.chatTF.htmlText = "Ну привет.";
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
			_player.x = stage.stageWidth / 2;
			_player.y = stage.stageHeight / 2;
			//_chat.scaleX = _chat.scaleY = (stage.stageWidth / _chat.width);
			_chat.y = stage.stageHeight;
		}
		
		private function onFrame( e:* ):void
		{
			if ( !stage || !_player )
				return;
			
			//Movement of the player
			_level.x = stage.stageWidth / 2 - _player.playerX;
			_level.y = stage.stageHeight / 2 - _player.playerY;
			//We are flying at space, yeah?
			_starField.moveStars( 1, 0 );
			
			//Send chat message
			if ( Keyboarder.instance.isKeyPressed( Keyboard.ENTER ) && _chat.messageTF.text != "" )
			{
				//Preparing data
				var data : Dictionary = new Dictionary();
				data["message"] = _chat.messageTF.text;
				data[Constants.KEY_ACTOR_NO] = PhotonPeer.getInstance().getActorNo();
				_peer.opRaiseEventWithCode( PhotonPeer.CODE_CHATMESSAGE, data );
				Utils.serverLog( "|CHAT| " + _login + ": " + _chat.messageTF.text );
				
				//View side
				addChatLine( _player.bodyColor, 0xFFFFFF, _player.playerName, _chat.messageTF.text );
				_player.parseEmotion( _chat.messageTF.text );
				var pos : Point = _level.globalToLocal( localToGlobal( new Point( _player.x + 16, _player.y - 48 ) ) )
				new FlyingMessage( pos.x, pos.y, _player.playerName + ": " + _chat.messageTF.text, _level );
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
			var currentPlayer : Player = getPlayerByActorNo( e.actorNo );
			currentPlayer.parseEmotion( e.message );
			new FlyingMessage( currentPlayer.x + 16, currentPlayer.y - 48, e.nickName + ": " + e.message, _level );
			var channel : SoundChannel = (new ChatMessageSound()).play();
			var vol : Number = 1.0 - (new Point( _player.playerX, _player.playerY ).subtract( new Point( currentPlayer.x, currentPlayer.y ) ).length / 1000);
			if ( vol < 0 )
				vol = 0;
			trace(vol);
			channel.soundTransform = new SoundTransform( vol, 0 );
			addChatLine( e.color, 0xFFFFFF, e.nickName, e.message );
		}
		
		private function onGameList( e : GameListEvent ):void
		{
			var list:Vector.<GameListEntry> = PhotonPeer.getInstance().getGameList();
			trace("So, we are connected. Game list (" + PhotonPeer.getInstance().getNumberOfGames() + " entries):" );
			if ( list.length > 0 )
			{
				//Show list
				for each ( var game : GameListEntry in list )
					trace( game.roomName );
				//Temporary solution: join first room				
				generateNameAndStoreAsActorProperty();
				PhotonPeer.getInstance().opJoinGame( list[0].roomName );
			}
			else
			{
				//No games, create the one
				var gp:GameProperties = GameProperties.createDefault();
				gp.customProperties = new Dictionary();
				gp.customProperties["starHolderId"] = _player.name;
				
				generateNameAndStoreAsActorProperty();
				
				PhotonPeer.getInstance().opCreateGame( "level1", gp );
			}
		}
		
		private function generateNameAndStoreAsActorProperty() : void {
			var ap : ActorProperties = PhotonPeer.getInstance().getLocalActorProperties();
			if (ap != null) {
				trace("ActorProperties found, Player's name is " + ap.actorName);
				return;
			} else {
				ap = ActorProperties.createDefault();
				ap.actorName = _player.playerName;
				ap.customProperties = new Dictionary();
				ap.customProperties["bodyColor"] = _bodyColor;
				ap.customProperties["faceColor"] = _faceColor;
				trace("generated ActorProperties, actor name: " + ap.actorName);
				PhotonPeer.getInstance().setLocalActorProperties(ap);
			}
			
			PhotonPeer.getInstance().addEventListener(JoinEvent.TYPE, onActorJoined);
			PhotonPeer.getInstance().addEventListener(LeaveEvent.TYPE, onActorLeaved );
		}
		
		private function onActorJoined( e : JoinEvent ):void
		{
			if ( !_players )
				_players = new Vector.<Player>();
				
			_chat.playerCountTF.text = "Сейчас где-то гуляет " + PhotonPeer.getInstance().getActorNumbers().length + " человек(а).";
			
			if (e.getActorNo() == PhotonPeer.getInstance().getActorNo()) 
			{
				for (var i : int = 0; i<PhotonPeer.getInstance().getActorNumbers().length; i++) {
					var aNo : int = PhotonPeer.getInstance().getActorNumbers()[i];
					var props : ActorProperties = PhotonPeer.getInstance().getActorPropertiesByActorNo(aNo);
					trace( "Already in room: " + props.actorName + "(" + aNo + ")" );
					//Create exists players:
					if ( aNo != PhotonPeer.getInstance().getActorNo() )
						addRemotePlayer( aNo );
				}
			}
			
			var ap : ActorProperties = PhotonPeer.getInstance().getActorPropertiesByActorNo(e.getActorNo());
			if ( ap )
			{
				if ( e.getActorNo() == PhotonPeer.getInstance().getActorNo() ) //Ow, it's me!
				{
					if ( ap.customProperties.hasOwnProperty("bodyColor") )
						_player.bodyColor = ap.customProperties["bodyColor"];
					if ( ap.customProperties.hasOwnProperty("faceColor") )
						_player.faceColor = ap.customProperties["faceColor"];
				}
				else
				{
					//Preparing data
					var data : Dictionary = new Dictionary();
					data["x"] = _player.playerX;
					data["y"] = _player.playerY;
					data[Constants.KEY_ACTOR_NO] = PhotonPeer.getInstance().getActorNo();
					var target : Vector.<int> = new Vector.<int>();
					target.push( e.getActorNo() );
					PhotonPeer.getInstance().opRaiseEventWithCode( PhotonPeer.CODE_PLAYERMOVE, data, 0, target );
					addRemotePlayer( e.getActorNo() );
					(new PlayerEnterSound()).play();
					addChatLine( 0x00FF00, 0xFFFF00, "System", "К нам заявился некий " + PhotonPeer.getInstance().getActorPropertiesByActorNo(e.getActorNo()).actorName + "." );
				}
				
				trace( "Player joined! Name: " + ap.actorName, ap.customProperties["bodyColor"] );
			}
		}
		
		private function addRemotePlayer( actorNo : int ):void
		{
			var props : ActorProperties = PhotonPeer.getInstance().getActorPropertiesByActorNo(actorNo);
			var newPlayer : Player = new Player( false, props.actorName );
			newPlayer.actorNo = actorNo;
			newPlayer.bodyColor = props.customProperties["bodyColor"];
			newPlayer.faceColor = props.customProperties["faceColor"];
			_players.push( newPlayer );
			_level.addChild( newPlayer );
		}
		
		private function onActorLeaved( e: LeaveEvent ):void
		{
			trace( "Leaved: " + PhotonPeer.getInstance().getActorPropertiesByActorNo(e.getActorNo()).actorName );
			var currentPlayer : Player = getPlayerByActorNo( e.getActorNo() );
			_level.removeChild( currentPlayer );
			_players.splice( _players.indexOf( currentPlayer ), 1 );
			
			_chat.playerCountTF.text = "Сейчас где-то гуляет " + PhotonPeer.getInstance().getActorNumbers().length + " человек(а).";
			(new PlayerLeaveSound()).play();
			addChatLine( 0x00FF00, 0xFFFF00, "System", "К сожалению, " + PhotonPeer.getInstance().getActorPropertiesByActorNo(e.getActorNo()).actorName + " покинул нас." );
		}
		
		private function onPlayerMoved( e : MoveEvent ):void
		{
			var currentPlayer : Player = getPlayerByActorNo( e.actorNo );
			if ( currentPlayer != null )
				currentPlayer.targetPos = new Point( e.x, e.y );
		}
		
		private function onPlayerPush( e : PushEvent ):void
		{
			var currentPlayer : Player = getPlayerByActorNo(e.actorNo);
			var pushPoint : Point = new Point( e.side == 1 ? 32 : (e.side == 3 ? -32 : 0), e.side == 2 ? -48 : (e.side == 4 ? 16 : 0) );
			if ( currentPlayer.localToGlobal( pushPoint ).subtract( new Point( stage.stageWidth / 2, stage.stageHeight / 2 ) ).length < 20 )
				_player.push( e.side );
		}
		
		private function getPlayerByActorNo( actorNo : int ):Player
		{
			var currentPlayer : Player;
			for each ( var pl : Player in _players )
				if ( pl.actorNo == actorNo )
				{
					currentPlayer = pl;
					break;
				}
				
			if ( !currentPlayer )
				trace("Can't find player with id", actorNo );
				
			return currentPlayer;
		}
		
	}
	
}