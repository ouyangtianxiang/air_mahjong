package ge.utils {
	
	import ge.global.GM;
	import ge.utils.tick.ITick;
	import ge.utils.tick.Tick;
	
	/**
	 * 移动
	 * @author Administrator
	 */
	public class Offset implements ITick {
		private var obj : *;
		
		/**
		 * 移动
		 * @param obj 作用对象
		 */
		public function Offset(obj : *) {
			this.obj = obj;
		}
		
		public function run(dt : Number) : void {
			obj.y += sy;
			obj.x += sx;
			frame--;
			if (frame <= 0) {
				obj.x = x;
				obj.y = y;
				stop();
				if (callback != null) {
					Tick.nextFrame(callback);
					callback = null;
				}
			}
		}
		
		private var frame : Number;
		public var x : Number;
		public var y : Number;
		private var sx : Number;
		private var sy : Number;
		public var isRun : Boolean;
		
		/**
		 * 开始移动
		 * @param time 时间(ms)
		 * @param x 目标 X
		 * @param y 目标 Y
		 */
		public function start(time : Number, x : Number, y : Number, callback : Function = null) : void {
			if (time > 0) {
				frame = time / (1000 / GM.stage.frameRate);
				this.sx = (x - obj.x) / frame;
				this.sy = (y - obj.y) / frame;
				this.x = x;
				this.y = y;
				this.callback = callback;
				isRun = true;
				Tick.addTick(this);
			}
		}
		
		private var callback : Function;
		
		/**
		 * 停止移动
		 */
		public function stop() : void {
			isRun = false;
			Tick.removeTick(this);
		}
	}
}
