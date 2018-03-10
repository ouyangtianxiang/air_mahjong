package ge.utils.tick {
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import ge.global.GM;
	
	/**
	 * @author Administrator
	 */
	public class Tick {
		private static var _it : Tick;
		
		public static function get it() : Tick {
			if (_it == null) {
				_it = new Tick();
			}
			return _it;
		}
		
		/**
		 * 本地时间(毫秒)
		 */
		private var time : Number;
		
		/**
		 * 服务器时间(毫秒)
		 */
		public function get Time() : Number {
			return time + difference;
		}
		
		/**
		 *服务器时间(秒)
		 */
		public function get Seconds() : Number {
			return (time + difference) / 1000;
		}
		
		/**
		 *服务器时间与本地时间差
		 */
		private var difference : Number = 0;
		
		/**
		 *服务器时间(毫秒)
		 */
		public function set Time(value : Number) : void {
			difference = value - time;
		}
		
		public function Tick() {
			GM.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 100);
			time = new Date().time;
		}
		
		private function onEnterFrame(event : Event) : void {
			var t : Number = new Date().time;
			var dt : Number = t - time;
			time = t;
			
			for each (var fun : Function in nextList) {
				delete nextList[fun];
				try {
					fun();
				} catch (error : Error) {
					trace(error.getStackTrace());
				}
			}
			for each (var tick : ITick in tickList) {
				try {
					tick.run(dt);
				} catch (error : Error) {
					trace(error.getStackTrace());
				}
			}
		}
		
		private var tickList : Dictionary = new Dictionary();
		
		public static function addTick(tick : ITick, frameRate : Number = 0) : void {
			var r : Run = it.tickList[tick];
			if (r) {
				r.play = true;
			} else {
				it.tickList[tick] = new Run(tick, frameRate);
			}
		}
		
		public static function removeTick(tick : ITick) : void {
			delete it.tickList[tick];
		}
		
		public static function stopTick(tick : ITick) : void {
			var r : Run = it.tickList[tick];
			if (r) {
				r.play = false;
			}
		}
		
		public static function updataTick(tick : ITick, vf : Number) : void {
			var run : Run = it.tickList[tick];
			if (run) {
				run.update(vf);
			}
		}
		
		private var nextList : Dictionary = new Dictionary();
		
		public static function nextFrame(fun : Function) : void {
			it.nextList[fun] = fun;
		}
	}
}
import ge.global.GM;
import ge.utils.tick.ITick;

class Run implements ITick {
	private var tick : ITick;
	public var play : Boolean = true;
	private var rate : uint;
	
	public function Run(tick : ITick, frameRate : Number) {
		this.tick = tick;
		rate = frameRate == 0 ? 1 : (GM.stage.frameRate / frameRate);
	
	}
	private var i : int = 0;
	
	public function run(dt : Number) : void {
		if (play) {
			i++;
			if (i >= rate) {
				i = 0;
				tick.run(dt);
			}
		}
	}
	
	public function update(vf : Number) : void {
		rate = vf == 0 ? 1 : (GM.stage.frameRate / vf);
	}
}
