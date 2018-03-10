package game.modules.window {
	import game.Game;

	import ge.events.GameEventDispatcher;
	import ge.gpu.display.GameObject;
	import ge.gpu.display.PureColor;

	public class WinModal extends GameObject {
		public var background:PureColor;
		private var _width:int;
		private var _height:int;

		public function WinModal(w:int, h:int, color:uint = 0x88000000) {
			this._width=w;
			this._height=h;
			x = (Game.UI_WIDTH - w) / 2;
			y = (Game.UI_HEIGHT - h) / 2;
			background = new PureColor(this, -x , -y , Game.UI_WIDTH, Game.UI_HEIGHT, color);
			background.mouseEnabled = true;
			this.mouseEnabled = true;
		}

		public function hide():void {
			this.remove();
		}

		public function show():void {
			GameEventDispatcher.ReleaseAll();
			Game.it.modal.addChild(this);
		}

		public function get width():Number {
			return _width;
		}

		public function get height():Number {
			return _height;
		}
	}
}
