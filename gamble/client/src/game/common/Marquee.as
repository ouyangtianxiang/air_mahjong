package game.common {
	import game.Game;
	
	import ge.gpu.display.GameObject;
	import ge.gpu.display.GameText;
	import ge.gpu.display.PureColor;
	import ge.utils.tick.ITick;
	import ge.utils.tick.Tick;
	
	/**
	 * 广播（全服的大喇叭）
	 * <p> 效果：水平向右遮罩滚动效果。
	 * <p> 位置：舞台居中靠顶位置。
	 * <p> 说明：新增一条消息时，会等待前条消息播完后再显示。
	 */
	public class Marquee extends GameObject implements ITick {
		private static var _it : Marquee;
		private static var _its : Marquee;
		
		public static function get it() : Marquee {
			if (_it == null) {
				_it = new Marquee(0);
			}
			return _it;
		}
		
		public static function get its() : Marquee {
			if (_its == null) {
				_its = new Marquee(155);
			}
			return _its;
		}
		
		
		
		private var pure : PureColor;
		
		public function Marquee(y : int) {
			pure = new PureColor(this, 0, y, Game.UI_WIDTH, 45, 0x55000000);
			txt = new GameText(this, 0, y + 5, 0xFFFF00, GameText.SIZE_L, true, true);
		}
		
		public override function onAddedStage() : void {
			Tick.addTick(this);
		}
		
		public override function onRemoveStage() : void {
			Tick.removeTick(this);
		}
		
		
		private var data : Array = [];
		private var txt : GameText;
		
		public function play(... arg : *) : void {
			play2(arg);
		}
		
		public function play2(arr : Array) : void {
			data.push(arr);
			if (parent == null) {
				show();
				next();
			}
		}
		
		private function equal(s : String) : Boolean {
			for each (var o : String in data) {
				if (s == o)
					return true;
			}
			return false;
		}
		
		private function next() : void {
			var o : Array = data[0];
			if (o != null) {
				txt.appends.apply(txt, o);
				txt.x = Game.UI_WIDTH;
			} else {
				remove();
			}
		}
		
		public function run(dt : Number) : void {
			txt.x -= 4;
			if (txt.x <= -txt.width) {
				data.shift();
				next();
			}
		}
		
		public function clear() : void {
			data = [];
			remove();
		}
		
		private function show() : void {
			if (parent == null) {
				Game.it.tip.addChild(this);
			}
		}
	}
}
