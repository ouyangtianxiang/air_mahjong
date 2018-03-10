package ge.utils {
	import ge.global.GM;
	import ge.utils.tick.ITick;
	import ge.utils.tick.Tick;

	/**在指定时间内将显示对象的某个特定属性的值，以当前值匀速的变化到指定的值
	 * @author txoy
	 */
	public class Tween implements ITick {
		private static function None(t : Number, b : Number, c : Number, d : Number) : Number {
			return c * t / d + b;
		}

		public static function RegularIn(t : Number, b : Number, c : Number, d : Number) : Number {
			return c * (t /= d) * t + b;
		}

		public static function RegularOut(t : Number, b : Number, c : Number, d : Number) : Number {
			return -c * (t /= d) * (t - 2) + b;
		}

		public static function RegularInOut(t : Number, b : Number, c : Number, d : Number) : Number {
			if ((t /= d / 2) < 1)
				return c / 2 * t * t + b;

			return -c / 2 * ((--t) * (t - 2) - 1) + b;
		}

		public static function StrongIn(t : Number, b : Number, c : Number, d : Number) : Number {
			return c * (t /= d) * t * t * t * t + b;
		}

		public static function StrongOut(t : Number, b : Number, c : Number, d : Number) : Number {
			return c * ((t = t / d - 1) * t * t * t * t + 1) + b;
		}

		public static function StrongInOut(t : Number, b : Number, c : Number, d : Number) : Number {
			if ((t /= d / 2) < 1)
				return c / 2 * t * t * t * t * t + b;

			return c / 2 * ((t -= 2) * t * t * t * t + 2) + b;
		}

		public static function ElasticIn(t : Number, b : Number, c : Number, d : Number, a : Number = 0, p : Number = 0) : Number {
			if (t == 0)
				return b;

			if ((t /= d) == 1)
				return b + c;

			if (!p)
				p = d * 0.3;

			var s : Number;
			if (!a || a < Math.abs(c)) {
				a = c;
				s = p / 4;
			} else {
				s = p / (2 * Math.PI) * Math.asin(c / a);
			}

			return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
		}

		public static function ElasticOut(t : Number, b : Number, c : Number, d : Number, a : Number = 0, p : Number = 0) : Number {
			if (t == 0)
				return b;

			if ((t /= d) == 1)
				return b + c;

			if (!p)
				p = d * 0.3;

			var s : Number;
			if (!a || a < Math.abs(c)) {
				a = c;
				s = p / 4;
			} else {
				s = p / (2 * Math.PI) * Math.asin(c / a);
			}

			return a * Math.pow(2, -10 * t) * Math.sin((t * d - s) * (2 * Math.PI) / p) + c + b;
		}

		public static function ElasticInOut(t : Number, b : Number, c : Number, d : Number, a : Number = 0, p : Number = 0) : Number {
			if (t == 0)
				return b;

			if ((t /= d / 2) == 2)
				return b + c;

			if (!p)
				p = d * (0.3 * 1.5);

			var s : Number;
			if (!a || a < Math.abs(c)) {
				a = c;
				s = p / 4;
			} else {
				s = p / (2 * Math.PI) * Math.asin(c / a);
			}

			if (t < 1) {
				return -0.5 * (a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
			}

			return a * Math.pow(2, -10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p) * 0.5 + c + b;
		}

		public static function BounceOut(t : Number, b : Number, c : Number, d : Number) : Number {
			if ((t /= d) < (1 / 2.75))
				return c * (7.5625 * t * t) + b;
			else if (t < (2 / 2.75))
				return c * (7.5625 * (t -= (1.5 / 2.75)) * t + 0.75) + b;
			else if (t < (2.5 / 2.75))
				return c * (7.5625 * (t -= (2.25 / 2.75)) * t + 0.9375) + b;
			else
				return c * (7.5625 * (t -= (2.625 / 2.75)) * t + 0.984375) + b;
		}

		public static function BounceIn(t : Number, b : Number, c : Number, d : Number) : Number {
			return c - BounceOut(d - t, 0, c, d) + b;
		}

		public static function BounceInOut(t : Number, b : Number, c : Number, d : Number) : Number {
			if (t < d / 2)
				return BounceIn(t * 2, 0, c, d) * 0.5 + b;
			else
				return BounceOut(t * 2 - d, 0, c, d) * 0.5 + c * 0.5 + b;
		}

		public static function BackIn(t : Number, b : Number, c : Number, d : Number, s : Number = 0) : Number {
			if (!s)
				s = 1.70158;
			return c * (t /= d) * t * ((s + 1) * t - s) + b;
		}

		public static function BackOut(t : Number, b : Number, c : Number, d : Number, s : Number = 0) : Number {
			if (!s)
				s = 1.70158;
			return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
		}

		public static function BackInOut(t : Number, b : Number, c : Number, d : Number, s : Number = 0) : Number {
			if (!s)
				s = 1.70158;
			if ((t /= d / 2) < 1)
				return c / 2 * (t * t * (((s *= (1.525)) + 1) * t - s)) + b;
			return c / 2 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2) + b;
		}

		// /目标对象
		private var obj : *;
		// 指示当前是否正在播放补间
		private var _isPlaying : Boolean;
		// /一个数字，指示要补间的目标对象属性的结束值
		// /计数
		private var currentCount : Number;
		// /播放的总帧数
		private var repeatCount : Number;
		private var End : Object;
		private var Begin : Object = {};
		private var fun : Function;

		/**
		 * 构造器
		 * @参数 obj:目标对象
		 */
		public function Tween(obj : *) {
			this.obj = obj;
		}

		public function run(dt : Number) : void {
			for (var p:String in End) {
				obj[p] = fun(currentCount, Begin[p], End[p] - Begin[p], repeatCount);
			}
			currentCount++;
			if (currentCount >= repeatCount) {
				stop();
				for (var p1:String in End) {
					obj[p1] = End[p1];
				}
				var callback:Function=this.callback;
				this.callback=null;
				if(callback!=null){
					callback();
				}
			}
		}

		private var callback:Function;
		/**
		 * 开始播放
		 * @参数 time:播放时间(毫秒)
		 * @参数 prop:受影响的属性的名称
		 * @参数 finish:结束值
		 * @参数 prop2:受影响的属性的名称
		 * @参数 finish2:结束值
		 */
		public function start(time : int, End : Object, fun : Function = null,callback:Function=null) : void {
			this.fun = fun == null ? None : fun;
			this.callback=callback;
			if (_isPlaying) {
				stop();
			}
			this.End = End;
			for (var p:String in End) {
				Begin[p] = obj[p];
			}
			currentCount = 1;
			repeatCount = time / 1000 * GM.stage.frameRate ;
			Tick.addTick(this);
			_isPlaying = true;
		}

		/**
		 * 停止播放
		 */
		public function stop() : void {
			Tick.removeTick(this);
			_isPlaying = false;
		}

		// /-----------------------------------------
		public function get isPlaying() : Boolean {
			return _isPlaying;
		}
	}
}
