package  {
	import de.exitgames.photon_as3.loadBalancing.LoadBalancedPeer;
	import de.exitgames.photon_as3.loadBalancing.model.constants.Constants;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import model.ChatEvent;
	import model.MoveEvent;
	import model.PushEvent;

	/**
	 * @author bL00RiSe
	 */
	public class PhotonPeer extends LoadBalancedPeer {
		
		public static const CODE_CHATMESSAGE : uint = 1;
		public static const CODE_PLAYERMOVE : uint = 2;
		public static const CODE_PLAYERPUSH : uint = 3;
		
		public static function getInstance():LoadBalancedPeer
        {
            if (_instance == null)
            {
                _instance = new PhotonPeer();
            }
            return _instance;
        }
		
		
		public function PhotonPeer() {
			_instance = this;
		}
		
		
		override protected function parseEventDataGame(eventCode:int, data:Dictionary):void
        {
            // parse event from gameserver

            switch (eventCode)
            {

                case CODE_CHATMESSAGE:
                {
					trace( "recieved a chat message for code " + eventCode + ", actorNo:" + data[Constants.KEY_DATA][Constants.KEY_ACTOR_NO] );
					dispatchEvent( new ChatEvent(data) );
                    break;
                }
				
				case CODE_PLAYERMOVE:
                {
					dispatchEvent( new MoveEvent(data) );
                    break;
                }
				
				case CODE_PLAYERPUSH:
                {
					dispatchEvent( new PushEvent(data) );
                    break;
                }

				default:
                {
                    trace("... redirecting event parsing to LoadBalancedPhoton");
                    super.parseEventDataGame(eventCode, data);
                    break;
                }
            }
        }
	}
}
