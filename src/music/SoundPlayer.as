package music
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;

	public class SoundPlayer
	{
		private var s:Sound;
		private var ch:SoundChannel;
		private var _isPlaying:Boolean;

		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}

		
		public function SoundPlayer(musicClass:Class)
		{
			s = new musicClass();
		}
		
		public function play(start:int = 0, loop:int = 0):void
		{
			if(!_isPlaying)
			{
				ch = s.play(start, loop);
				ch.addEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
				_isPlaying = true;
			}
		}
		
		public function stop():void
		{
			if(_isPlaying)
			{
				ch.stop();
				_isPlaying = false;
			}
		}
		
		private function handleSoundComplete(ev:Event):void
		{
			_isPlaying = false;
		}
	}
}