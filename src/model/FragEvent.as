package model 
{
	import de.exitgames.photon_as3.loadBalancing.model.constants.Constants;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class FragEvent extends Event 
	{
		public static const TYPE : String = "fragEvent";
		
		private var _count : String;
		private var _actorNo : int;
		
		public function FragEvent(  data : Dictionary  ) 
		{ 
			super( TYPE );
			_actorNo = data[Constants.KEY_DATA][Constants.KEY_ACTOR_NO];
			_count = data[Constants.KEY_DATA]["count"];
		} 
		
		public function get nickName() : String { return PhotonPeer.getInstance().getActorPropertiesByActorNo( _actorNo ).actorName; }
		public function get count() : String { return _count; }
		public function get actorNo() : int { return _actorNo; }
		
	}
	
}