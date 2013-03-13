package model 
{
	import de.exitgames.photon_as3.loadBalancing.model.constants.Constants;
	import flash.events.Event;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author qwfd
	 */
	public class PushEvent extends Event
	{
		public static const TYPE : String = "pushEvent";
		
		private var _side : int;
		private var _actorNo : int;
		
		public function PushEvent( data : Dictionary ) 
		{
			super( TYPE );
			_actorNo = data[Constants.KEY_DATA][Constants.KEY_ACTOR_NO];
			_side = data[Constants.KEY_DATA]["side"];
		}
		
		public function get nickName() : String { return PhotonPeer.getInstance().getActorPropertiesByActorNo( _actorNo ).actorName; }
		public function get side() : int { return _side; }
		public function get actorNo() : int { return _actorNo; }
	}

}