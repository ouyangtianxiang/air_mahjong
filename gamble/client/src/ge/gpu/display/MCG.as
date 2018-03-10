package ge.gpu.display {
	import ge.utils.tick.ITick;
	import ge.utils.tick.Tick;
	
	public class MCG extends GameObject implements ITick {
		private var fram : uint;
		private var duration : uint;
		private var vector : Vector.<MCBase>;
		private var callback : Function;
		private var wing : MC;
		
		public function MCG(c : GameObject, x : int, y : int, num : uint, isWing : Boolean = false) {
			this.x = x;
			this.y = y;
			c.addChild(this);
			if (isWing) {
				wing = new MC(this, 0, 0);
			}
			vector = new Vector.<MCBase>(num);
			for (var i : int = 0; i < num; i++) {
				vector[i] = new MCBase();
				this.addChild(vector[i]);
			}
		}
		private var url : String;
		
		public function loadWing(url : String, y : int,onLoad:Function=null) : void {
			if (url) {
				if (this.url != url) {
					this.url = url;
					wing.y = y;
					wing.load(url,onLoad);
					wing.play();
				}
			} else {
				wing.clear();
				this.url = null;
			}
		}
		
		public function load(i : int, url : String,onLoad:Function=null) : void {
			if (url == null) {
				vector[i].clear();
			} else {
				vector[i].load(url,onLoad);
			}
		}
		
		public function g(i : int, value : *) : void {
			vector[i].g = value;
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
			this.fram = 0;
			this.duration = duration;
			this.callback = callback;
			isPlayer = true;
			i = 0;
			if (stage) {
				Tick.addTick(this);
			}
		}
		
		public var isPlayer : Boolean;
		
		public function stop() : void {
			isPlayer = false;
			Tick.stopTick(this);
		}
		public var i : int;
		public var times : int = 3
		
		public function run(dt : Number) : void {
			if (fram >= vector[0].len) {
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
				fram = 0;
			}
			if (i % times == 0) {
				for each (var mc : MCBase in vector) {
					mc.frame(fram);
				}
				fram++;
			}
			i++;
		}
		
		public function insertFrame(fram : int) : void {
			stop();
			this.fram = fram;
			for each (var mc : MCBase in vector) {
				mc.frame(fram);
			}
		}
		
		public override function setColor(value : uint, overlap : Boolean = false) : void {
			_color = value;
			for each (var o : GameObject in vector) {
				o.setColor(value, overlap);
			}
		}
	
	}
}
