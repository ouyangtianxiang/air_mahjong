package game.common {
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import game.Game;
	
	import ge.gpu.display.GameClipSprite;
	import ge.gpu.display.GameText;
	import ge.utils.tick.ITick;
	import ge.utils.tick.Tick;
	
	public class Tip extends GameClipSprite implements ITick {
		private static const Y : int = 100;
		private static const ROW_NUM : int = 5;
		private static const ROW_HEIGHT : int = 35;
		private static const TIME : int = 2000;
		private static const SPEED : int = 2;
		
		private static var _it : Tip;
		
		public static function get it() : Tip {
			if (_it == null) {
				_it = new Tip();
			}
			return _it;
		}
		
		private var list : Array = [];
		private var array : Array = [];
		
		public function Tip() {
			this.y = Y;
			this.scrollRect = new Rectangle(0, 0, Game.UI_WIDTH, (ROW_NUM - 1) * ROW_HEIGHT);
			for (var i : int = 0; i < ROW_NUM; i++) {
				var txt : GameText = new GameText(this, Game.UI_WIDTH / 2, i * ROW_HEIGHT, 0xFFFFFF, GameText.SIZE_L, true, true);
				txt.anchor(0.5, 0);
				txt.visible = false;
				empty.push(txt);
				list.push(txt);
			}
		}
		
		public function run(dt : Number) : void {
			for each (var txt : GameText in list) {
				txt.y -= SPEED;
			}
			var t : GameText = array[0];
			if (t.y < -ROW_HEIGHT) {
				t.visible = false;
				t.y += ROW_HEIGHT * ROW_NUM;
				empty.push(array.shift());
				Tick.removeTick(this);
				isTick = false;
				start();
			}
		}
		private var time : Dictionary = new Dictionary();
		private var empty : Array = [];
		private var isTick : Boolean
		
		private function timeOut(t : int) : void {
			if (!isTick) {
				isTick = true;
				var st : int = TIME - (Tick.it.Time - t);
				if (st > 0) {
					setTimeout(Tick.addTick, st, this);
				} else {
					Tick.addTick(this);
				}
			}
		}
		
		private function start() : void {
			if (data.length > 0 && empty.length > 0) {
				var txt : GameText = empty.shift();
				txt.visible = true;
				time[txt] = Tick.it.Time;
				txt.appends.apply(txt,data.shift());
				array.push(txt);
			}
			if (array.length > 0) {
				timeOut(time[array[0]]);
			} else {
				remove();
			}
		}
		
		private var data : Array = [];
		
		public function play(...arg:*) : void {
			data.push(arg);
			start();
			if (parent == null) {
				Game.it.tip.addChild(this)
			}
		}
	}
}
