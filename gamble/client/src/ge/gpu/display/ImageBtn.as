package ge.gpu.display {
	import game.utils.Music;
	
	import ge.events.GameEvent;
	
	public class ImageBtn extends Image {
		
		public function ImageBtn(c : GameObject, x : int, y : int, img : String =null) {
			super(c, x, y, img);
			mouseEnabled = true;
			addEventListener(GameEvent.DOWN, onDown);
			addEventListener(GameEvent.UP, onUp);
			anchor(0.5,0.5);
		}
		
		protected function onDown(go : Image) : void {
			Music.it.Effect(1);
			go.scale = 0.9;
		}
		
		protected function onUp(go : Image) : void {
			if (go.scaleX < 1) {
				go.scale = 1;
			}
		}
		
		private var _click : Boolean = true;
		
		public function get click() : Boolean {
			return _click;
		}
		
		public function set click(value : Boolean) : void {
			_click = value;
			gray = !value;
			mouseEnabled = value;
		}
		
		private var _select : Boolean;
		
		public function get select() : Boolean {
			return _select;
		}
		
		public function set select(value : Boolean) : void {
			_select = value;
			onUp(this);
		}
		
		public var _mark : Image;
		
		public function mark(value : String) : void {
			if (_mark == null) {
				_mark = new Image(this, 0, 0, value);
				_mark.anchor(0.5,0.5);
			}
		}
	}
}
