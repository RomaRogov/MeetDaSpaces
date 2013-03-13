package model 
{
	import de.exitgames.photon_as3.loadBalancing.model.constants.Constants;
	import flash.events.Event;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class ChatEvent extends Event
	{
		public static const TYPE : String = "chatMessage";
		
		private var _message : String;
		private var _actorNo : int;
		
		public function ChatEvent( data : Dictionary ) 
		{
			super( TYPE );
			_actorNo = data[Constants.KEY_DATA][Constants.KEY_ACTOR_NO];
			_message = data[Constants.KEY_DATA]["message"];
		}
		
		public function get nickName() : String { return PhotonPeer.getInstance().getActorPropertiesByActorNo( _actorNo ).actorName; }
		public function get message() : String { return _message; }
		public function get color() : int { return PhotonPeer.getInstance().getActorPropertiesByActorNo( _actorNo ).customProperties["bodyColor"]; }
		public function get actorNo() : int { return _actorNo; }
		
	}

}