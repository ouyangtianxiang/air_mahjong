package game.effect {
	
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import game.modules.window.WinModal;
	
	import ge.gpu.display.Image;
	import ge.utils.tick.ITick;
	import ge.utils.tick.Tick;
	
	public class LoadingTip extends WinModal implements ITick {
		private static var _it : LoadingTip;
		
		public static function get it() : LoadingTip {
			if (_it == null) {
				_it = new LoadingTip();
			}
			return _it;
		}
		private var img : Image;
		
		public function LoadingTip() {
			super(64, 64, 0x00000000);
			img = new Image(this, 32, 32, 110);
			img.anchor(16, 16);
			img.scale = 2;
			img.visible = false;
		}
		private var timer : uint;
		
		public override function show() : void {
			super.show();
			clearTimeout(timer);
			timer = setTimeout(callback, 2000);
		}
		
		private function callback() : void {
			img.visible = true;
			Tick.addTick(this);
		}
		
		public override function hide() : void {
			super.hide();
			img.visible = false;
			clearTimeout(timer);
			Tick.removeTick(this);
		}
		
		public function run(dt : Number) : void {
			img.rotation -= 15;
		}
	
	
	}
}
