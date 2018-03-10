package game.utils {
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;
	
	import game.res.LoadBinary;
	
	/**
	 * @author tianxiang.ouyang
	 */
	public class Music {
		private static var _it : Music;
		
		public static function get it() : Music {
			if (_it == null) {
				_it = new Music();
			}
			return _it;
		}
		public var song : SoundChannel;
		public var songEffect : SoundChannel;
		
		private var activaie : Boolean = true;
		
		public function onActivaie() : void {
			activaie = true;
			play();
		}
		
		public function onDeactivate() : void {
			activaie = false;
			stopBgMusic();
		}
		
		private var _bgMusicONOFF : Boolean = true;
		private var _soundEffectONOFF : Boolean = true;
		
		private var bgMusic : int;
		//是否等待音乐播放完后再播下一首(战斗胜利和失败音乐)
		private var force : Boolean;
		//背景音乐播放次数，默认循环播放
		private var count : int;
		
		public function BGMusic(bgMusic : int, force : Boolean = false, count : int = 0) : void {
			if (bgMusic > 0) {
				this.bgMusic = bgMusic;
				this.count = count;
				if (!this.force) {
					play();
				}
				this.force = force;
			}
		}
		
		public function stopBgMusic() : void {
			if (song != null) {
				song.stop();
				song.removeEventListener(Event.SOUND_COMPLETE, end);
			}
		}
		
		private function play() : void {
			if (_bgMusicONOFF && activaie && bgMusic > 0) {
				var sound : Sound = new Sound();
				new LoadBinary("res/music/bgMusic/" + bgMusic + ".mp3", function(bytes : ByteArray) : void {
					sound.loadCompressedDataFromByteArray(bytes, bytes.length);
					bytes.clear();
					SoundPlay(sound);
				});
			}
		}
		
		private function SoundPlay(sound : Sound) : void {
			stopBgMusic();
			try {
				song = sound.play(0, 0, bgSoundTransform);
				if (song) {
					song.addEventListener(Event.SOUND_COMPLETE, end);
				}
			} catch (error : Error) {
				
			}
		}
		
		private function end(event : Event) : void {
			if (count != 1) {
				BGMusic(bgMusic, force, count - 1);
			}
		}
		
		
		private var Effects : Object = new Object();
		
		public function preloadEffect(index : int, callback : Function = null) : void {
			var effect : Sound = Effects[index];
			if (effect == null) {
				effect = new Sound();
				new LoadBinary("res/music/effect/" + index + ".mp3", function(bytes : ByteArray) : void {
					effect.loadCompressedDataFromByteArray(bytes, bytes.length)
					bytes.clear();
					Effects[index] = effect;
					if (callback != null) {
						callback();
					}
				});
			}
		}
		
		public function Effect(index : int) : void {
			if (index > 0 && _soundEffectONOFF && activaie) {
				var effect : Sound = Effects[index];
				if (effect) {
					playEffect(effect);
				} else {
					trace("NOT Preload Music Effect:", index);
				}
			}
		}
		
		private var songEffect2s : Object = {};
		private var songEffect2 : SoundChannel;
		
		public function Effect2(index : int) : void {
			if (songEffect2) {
				songEffect2.stop();
			}
			var effect2 : Sound = songEffect2s[index];
			if (effect2) {
				songEffect2 = effect2.play();
			} else {
				effect2 = new Sound();
				songEffect2s[index] = effect2;
				new LoadBinary("res/music/effect/" + index + ".mp3", function(bytes : ByteArray) : void {
					effect2.loadCompressedDataFromByteArray(bytes, bytes.length);
					songEffect2 = effect2.play();
					bytes.clear();
				});
			}
		}
		
		protected function playEffect(effect : Sound) : void {
			songEffect = effect.play(0, 0, effectSoundTransform);
		}
		
		public function stopEffect() : void {
			if (songEffect != null) {
				songEffect.stop();
			}
		}
		
		private var effectSoundTransform : SoundTransform = new SoundTransform();
		private var bgSoundTransform : SoundTransform = new SoundTransform();
		
		public function set soundEffectONOFF(value : Boolean) : void {
			_soundEffectONOFF = value;
		}
		
		public function set soundEffectVolume(value : Number) : void {
			volume2 = value;
			musicONOFF();
		}
		
		private var volume1 : Number = 1;
		private var volume2 : Number = 1;
		
		public function set bgMusicONOFF(value : Boolean) : void {
			_bgMusicONOFF = value;
			if (_bgMusicONOFF) {
				BGMusic(bgMusic);
			} else {
				stopBgMusic();
			}
		}
		
		public function musicONOFF() : void {
			bgSoundTransform.volume = volume1;
			effectSoundTransform.volume = volume2;
			if (song != null) {
				song.soundTransform = bgSoundTransform;
			}
			if (songEffect != null) {
				songEffect.soundTransform = effectSoundTransform;
			}
		}
		
		public function set bgMusicVolume(value : Number) : void {
			volume1 = value;
			musicONOFF();
		}
	}
}

