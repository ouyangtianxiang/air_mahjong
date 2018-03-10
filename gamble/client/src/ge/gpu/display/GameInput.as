package ge.gpu.display {
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import ge.events.GameEvent;
	import ge.events.GameEventDispatcher;
	import ge.utils.tick.Tick;
	
	public class GameInput extends GameObject {
		private var _txt : TextField = new TextField();
		private var txt : GameText;
		private var format : TextFormat;
		private var value : String = "";
		
		public function GameInput(c : GameObject, x : int, y : int, w : int, h : int, color : uint = 0xFFFFFF, size : uint = GameText.SIZE_M) {
			this.x = x;
			this.y = y;
			c.addChild(this);
			mouseEnabled = true;
			
			var bg : PureColor = new PureColor(this, 0, 0, w, h, 0x33FF0000);
			bg.addEventListener(GameEvent.DOWN, onDown);
			bg.mouseEnabled = true;
			
			format = new TextFormat("microsoft yahei", size, color, true);
			txt = new GameText(this, 2, 2, color, size, false, false, w);
			_txt.width = w;
			_txt.height = h;
			_txt.type = TextFieldType.INPUT;
			_txt.addEventListener(FocusEvent.FOCUS_OUT, onFousOut);
			_txt.addEventListener(Event.CHANGE, onChange);
			
			_txt.background = true;
			_txt.backgroundColor = 0x111111;
			_txt.textColor = color;
			if (h > size * 2) {
				_txt.multiline = true;
			} else {
				_txt.multiline = false;
			}
			_txt.text = "0";
			_txt.defaultTextFormat=format;
			_txt.setTextFormat(format);
			_txt.text = "";
		}
		
		public function set wordWrap(iswordWrap : Boolean) : void {
			_txt.wordWrap = iswordWrap;
		}
		
		public function get text() : String {
			return _txt.text;
		}
		
		protected override function onPosition() : void {
			_txt.x = absX / Game3D.it.scaleX;
			_txt.y = absY / Game3D.it.scaleY;
			_txt.scaleX = absScaleX / Game3D.it.scaleX;
			_txt.scaleY = absScaleY / Game3D.it.scaleY;
		}
		
		public function set text(value : String) : void {
			this.value = value;
			txt.text = value;
			_txt.text = value;
			_txt.defaultTextFormat=format;
			_txt.setTextFormat(format);
		}
		
		private function onDown(go : GameObject) : void {
			if (_txt.parent == null) {
				stage.addChild(_txt);
				stage.focus = _txt;
				_txt.text = value;
				_txt.setSelection(_txt.length, _txt.length);
				_txt.defaultTextFormat=format;
				_txt.setTextFormat(format);
			}
			Tick.nextFrame(GameEventDispatcher.ReleaseAll);
		}
		
		protected function onChange(event : Event) : void {
			if (max > 0) {
				if (Number(text) > max) {
					_txt.text = max.toString();
				}
			}
			_txt.defaultTextFormat=format;
			_txt.setTextFormat(format);
		}
		
		public override function onRemoveStage() : void {
			super.onRemoveStage();
			cancel();
		}
		
		protected function onFousOut(event : FocusEvent) : void {
			cancel();
		}
		
		private function cancel() : void {
			if (_txt.parent) {
				_txt.parent.removeChild(_txt);
			}
			value = _txt.text;
			txt.text = value;
		}
		
		public function get length() : int {
			return text.replace(/[^\x00-\xff]/g, "xx").length;
		}
		
		private var _maxChars : uint;
		
		public function set maxChars(value : uint) : void {
			_maxChars = value;
			_txt.addEventListener(TextEvent.TEXT_INPUT, onTextInput, false, 100);
		}
		
		private function onTextInput(event : TextEvent) : void {
			if (length >= _maxChars) {
				event.preventDefault();
			}
		}
		
		private var max : uint;
		
		public function set maxNumber(value : uint) : void {
			this.max = value;
			_txt.addEventListener(TextEvent.TEXT_INPUT, onTextInput2, false, 100);
		}
		
		protected function onTextInput2(event : TextEvent) : void {
			if (isNaN(Number(event.text))) {
				event.preventDefault();
			}
		}
	}
}
