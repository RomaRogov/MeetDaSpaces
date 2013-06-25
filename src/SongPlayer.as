package  
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author bL00RiSe
	 */
	public class SongPlayer 
	{
		private static const authors : Array = [ "cosmos70", "vrumzsssr", "entershikari", "scaly-whale", "kimandburan" ];
		
		private var _song : Sound;
		private var _channel : SoundChannel;
		private var _interface : SongPlayerInterface;
		private var _playPos : uint = 0;
		
		public function SongPlayer( playerMC : SongPlayerInterface ) 
		{
			_interface = playerMC;
			
			onSongComplete();
			
			_interface.addEventListener( Event.ENTER_FRAME, onFrame );
			
			_interface.soundNextBtn.gotoAndStop(1);
			_interface.soundSwitcher.gotoAndStop(1);
			_interface.soundSwitcher.addEventListener( MouseEvent.CLICK, switchSound );
			_interface.soundNextBtn.addEventListener( MouseEvent.CLICK, onNextSong );
		}
		
		private function switchSound( e:* ):void
		{
			if ( !_channel )
				return;
				
			_interface.soundSwitcher.gotoAndStop( _interface.soundSwitcher.currentFrame == 1 ? 2 : 1 );
			if ( _interface.soundSwitcher.currentFrame == 2 )
			{
				_playPos = _channel.position;
				_channel.stop();
			}
			else
				_channel = _song.play( _playPos );
		}
		
		private function onFrame( e:* ):void
		{
			if ( !_channel )
				return;
			var c : Number = _channel.position / _song.length;
			_interface.slider.x = _interface.bar.x + (_interface.bar.width-3) * c;
		}
		
		private function onNextSong( e:* ):void 
		{
			if ( _channel )
				_channel.stop();
			onSongComplete();
		}
		
		private function onSongComplete( e:* = null ):void
		{
			trace("Playing next song...");
			if ( _channel )
				_channel.removeEventListener( Event.SOUND_COMPLETE, onSongComplete );
			_interface.soundNextBtn.mouseEnabled = false;
			_interface.soundNextBtn.gotoAndStop(2);
			
			SoundCloudUtils.GetTracks( authors[Math.floor(Math.random() * authors.length)], 
			function( tracks:Array ):void
			{
				var selectedTrack : Object = tracks[Math.floor(Math.random() * tracks.length)];
				_song = SoundCloudUtils.GetSound( selectedTrack );
				_channel = _song.play();
				if ( _channel )
					_channel.addEventListener(Event.SOUND_COMPLETE, onSongComplete );
				
				_interface.authorNameTF.text = selectedTrack.user.username;
				_interface.songNameTF.text = selectedTrack.title;
				_interface.soundNextBtn.mouseEnabled = true;
				_interface.soundNextBtn.gotoAndStop(1);
			}, true );
		}
	}

}