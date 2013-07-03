package model 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import view.FlyingMessage;
	import view.Level;
	import view.Player;
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
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author qwfd
	 */
	public class Room extends EventDispatcher
	{
		private var _level : Level;
		private var _peer : LoadBalancedPeer;
		private var _players : Vector.<Player>;
		private var _player : Player;
		private var _playerCount : int;
		
		public function Room( level : Level, player : Player ) 
		{
			_level = level;
			_player = player;
			_peer = PhotonPeer.getInstance();
			_playerCount = 1;
			
			//So, we are connected. Let's get (or generate) actor's props!
			var ap : ActorProperties = _peer.getLocalActorProperties();
			if (ap != null) {
				trace("ActorProperties found, Player's name is " + ap.actorName);
			} else {
				ap = ActorProperties.createDefault();
				ap.actorName = _player.playerName;
				
				ap.customProperties = new Dictionary();
				ap.customProperties["bodyColor"] = _player.bodyColor;
				ap.customProperties["faceColor"] = _player.faceColor;
				trace("generated ActorProperties, actor name: " + ap.actorName);
				_peer.setLocalActorProperties(ap);
			}
			
			//Add listeners for main actors events
			_peer.addEventListener(JoinEvent.TYPE, onActorJoined);
			_peer.addEventListener(LeaveEvent.TYPE, onActorLeaved );
			//Add listeners for actors behaviour
			_peer.addEventListener( ChatEvent.TYPE, applyChatMessage );
			_peer.addEventListener( MoveEvent.TYPE, onPlayerMoved );
			_peer.addEventListener( PushEvent.TYPE, onPlayerPush );
		}
		
		//Someone joined the room
		private function onActorJoined( e : JoinEvent ):void
		{
			if ( !_players )
				_players = new Vector.<Player>();
				
			_playerCount = _peer.getActorNumbers().length;
			
			//in 
			var ap : ActorProperties = _peer.getActorPropertiesByActorNo(e.getActorNo());
			if ( ap )
			{
				if ( e.getActorNo() == _peer.getActorNo() ) //Ow, it's me!
				{
					if ( ap.customProperties.hasOwnProperty("bodyColor") )
						_player.bodyColor = ap.customProperties["bodyColor"];
					if ( ap.customProperties.hasOwnProperty("faceColor") )
						_player.faceColor = ap.customProperties["faceColor"];
						
					//So, get others!
					for (var i : int = 0; i < _peer.getActorNumbers().length; i++)
					{ 
						var aNo : int = _peer.getActorNumbers()[i];
						var props : ActorProperties = _peer.getActorPropertiesByActorNo(aNo);
						trace( "Already in room: " + props.actorName + "(" + aNo + ")" );
						//Create exists players:
						if ( aNo != _peer.getActorNo() )
							addRemotePlayer( aNo );
					}
					
					//Tell them about my placement
					_player.sendPlaceByNet();
				}
				else
				{
					//Newbie! He should know where am I
					var data : Dictionary = new Dictionary();
					data["x"] = _player.playerX;
					data["y"] = _player.playerY;
					data[Constants.KEY_ACTOR_NO] = _peer.getActorNo();
					var target : Vector.<int> = new Vector.<int>();
					target.push( e.getActorNo() );
					_peer.opRaiseEventWithCode( PhotonPeer.CODE_PLAYERMOVE, data, 0, target );
					addRemotePlayer( e.getActorNo() );
					dispatchEvent( e );
				}
				
				trace( "Player joined event! Name: " + ap.actorName, ap.customProperties["bodyColor"] );
			} 
			else 
				trace( "ActorProperties is null!");
		}
		
		//Add player from net
		private function addRemotePlayer( actorNo : int ):void
		{
			var props : ActorProperties = _peer.getActorPropertiesByActorNo(actorNo);
			var newPlayer : Player = new Player( false, props.actorName );
			newPlayer.actorNo = actorNo;
			newPlayer.bodyColor = props.customProperties["bodyColor"];
			newPlayer.faceColor = props.customProperties["faceColor"];
			_players.push( newPlayer );
			_level.addPlayer( newPlayer );
		}
		
		//Remove player from net
		private function onActorLeaved( e: LeaveEvent ):void
		{
			trace( "Leaved: " + _peer.getActorPropertiesByActorNo(e.getActorNo()).actorName );
			var currentPlayer : Player = getPlayerByActorNo( e.getActorNo() );
			currentPlayer.removeFromParent( true );
			_players.splice( _players.indexOf( currentPlayer ), 1 );
			
			_playerCount = _peer.getActorNumbers().length;
			dispatchEvent( e );
		}
		
		//Get other player's position
		private function onPlayerMoved( e : MoveEvent ):void
		{
			var currentPlayer : Player = getPlayerByActorNo( e.actorNo );
			if ( currentPlayer != null )
				currentPlayer.targetPos = new Point( e.x, e.y );
		}
		//Someone pushing someone :)
		private function onPlayerPush( e : PushEvent ):void
		{
			var currentPlayer : Player = getPlayerByActorNo(e.actorNo);
			var pushPoint : Point = new Point( e.side == 1 ? 32 : (e.side == 3 ? -32 : 0), e.side == 2 ? -48 : (e.side == 4 ? 16 : 0) );
			//if ( currentPlayer.localToGlobal( pushPoint ).subtract( new Point( stage.stageWidth / 2, stage.stageHeight / 2 ) ).length < 20 )
			//	_player.push( e.side );
		}
		
		//You got a message from chat
		private function applyChatMessage( e : ChatEvent ):void
		{ 
			var currentPlayer : Player = getPlayerByActorNo( e.actorNo );
			currentPlayer.parseEmotion( e.message );
			//TODO: Flying message
			FlyingMessage.show( currentPlayer.x + 16, currentPlayer.y - 48, e.nickName + ": " + e.message, _level );
			
			dispatchEvent( e );
		}
		
		//You wanna send message to chat
		public function sendChatMessage( msg : String ):void
		{
			//Preparing data
			var data : Dictionary = new Dictionary();
			data["message"] = msg;
			data[Constants.KEY_ACTOR_NO] = _peer.getActorNo();
			_peer.opRaiseEventWithCode( PhotonPeer.CODE_CHATMESSAGE, data );
			Utils.serverLog( "|CHAT| " + _player.playerName + ": " + msg );
		}
		
		public function deinit():void
		{
			//Add listeners for main actors events
			_peer.removeEventListener(JoinEvent.TYPE, onActorJoined);
			_peer.removeEventListener(LeaveEvent.TYPE, onActorLeaved );
			//Add listeners for actors behaviour
			_peer.removeEventListener( ChatEvent.TYPE, applyChatMessage );
			_peer.removeEventListener( MoveEvent.TYPE, onPlayerMoved );
			_peer.removeEventListener( PushEvent.TYPE, onPlayerPush );
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