package game.modules {
	import flash.events.Event;
	
	import game.Game;
	
	import ge.global.Atf;
	import ge.gpu.display.GameObject;
	import ge.gpu.display.Image;
	import ge.utils.Shake;
	
	public class ModuleBase extends GameObject {
		private var bg : Image;
		
		public function ModuleBase(bgImg:String) {
			mouseEnabled = true;
			bg = new Image(this, 0, 0);
			bg.addEventListener(Event.COMPLETE, onCompleteBG);
			bg.load("res/bg/" +bgImg+Atf);
		}
		
		protected function onCompleteBG(bg : Image) : void {
			bg.scaleX = width / bg.width;
			bg.scaleY = height / bg.height;
		}
		
		public function hide() : void {
			remove();
		}
		
		public function show() : void {
			Game.it.sington.addChild(this);
		}
		
		public function get width() : Number {
			return Game.UI_WIDTH;
		}
		
		public function get height() : Number {
			return Game.UI_HEIGHT;
		}
		
		/**
		 * 震动
		 */
		public function shake(sum : int, type : int = 0) : void {
			Shake.it.start(this, sum, type);
		}
	}
}
