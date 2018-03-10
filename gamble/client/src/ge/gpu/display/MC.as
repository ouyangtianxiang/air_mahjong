package ge.gpu.display {
	import ge.utils.tick.ITick;
	import ge.utils.tick.Tick;
	
	public class MC extends MCBase implements ITick {
		
		private var _fram : uint;
		private var duration : uint;
		private var callback : Function;
		
		public function MC(c : GameObject, x : int, y : int) {
			this.x = x;
			this.y = y;
			c.addChild(this);
		}
		
		public override function onAddedStage() : void {
			if (isPlayer) {
				Tick.addTick(this);
			}
		}
		
		public override function onRemoveStage() : void {
			Tick.removeTick(this);
		}
		
		public function play(duration : uint = 0, callback : Function = null) : void {
			this._fram = 0;
			this.i = 0;
			this.duration = duration;
			this.callback = callback;
			isPlayer = true;
			if (stage) {
				run(0);
				Tick.addTick(this);
			}
		}
		
		private var isPlayer : Boolean;
		
		public function stop() : void {
			isPlayer = false;
			Tick.stopTick(this);
		}
		public var i : int;
		public var times : int = 3
		
		public function run(dt : Number) : void {
			if (_fram >= len) {
				if (duration == 1) {
					stop();
					if (callback != null) {
						var _callback : Function = callback;
						callback = null;
						_callback();
						return;
					}
				} else {
					duration--;
				}
				_fram = 0;
			}
			if (i % times == 0) {
				frame(_fram);
				_fram++;
			}
			i++;
		}
	}
}
