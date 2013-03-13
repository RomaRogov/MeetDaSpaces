package model 
{
	import de.exitgames.photon_as3.loadBalancing.model.constants.Constants;
	import flash.events.Event;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class MoveEvent extends Event
	{
		public static const TYPE : String = "moveEvent";
		
		private var _x : int;
		private var _y : int;
		private var _actorNo : int;
		
		public function MoveEvent( data : Dictionary ) 
		{
			super( TYPE );
			_actorNo = data[Constants.KEY_DATA][Constants.KEY_ACTOR_NO];
			_x = data[Constants.KEY_DATA]["x"];
			_y = data[Constants.KEY_DATA]["y"];
		}
		
		public function get nickName() : String { return PhotonPeer.getInstance().getActorPropertiesByActorNo( _actorNo ).actorName; }
		public function get x() : int { return _x; }
		public function get y() : int { return _y; }
		public function get color() : int { return PhotonPeer.getInstance().getActorPropertiesByActorNo( _actorNo ).customProperties["bodyColor"]; }
		public function get actorNo() : int { return _actorNo; }
	}

}