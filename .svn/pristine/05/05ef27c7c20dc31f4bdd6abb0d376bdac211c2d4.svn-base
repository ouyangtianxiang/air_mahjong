package ge.net.view {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	/**
	 * 输入文本
	 * @author tianxiang.ouyang
	 */
	public class VInput extends TextField {
		public var format : TextFormat;

		public function VInput(space : Sprite, text : String, x : Number, y : Number, w : uint, h : uint = 20, color : uint = 0, size : uint = 12,bold:Boolean=false) {
			if (space != null) {
				space.addChild(this);
			}
			this.x = x;
			this.y = y;
			this.textColor = color;
			this.text = text;
			format = new TextFormat("NSimSun", size, color,bold);
			this.setTextFormat(format);
			this.width = w;
			height = h;
			if (h > 20) {
				multiline = true;
				wordWrap = true;
			}
			cacheAsBitmap = true;
			selectable = true;
			type = TextFieldType.INPUT;
			this.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		private function onKeyDown(event : KeyboardEvent) : void {
			event.stopPropagation();
		}

		public function set align(value : String) : void {
			format.align = value;
			this.setTextFormat(format);
		}

		public override function set maxChars(value : int) : void {
			super.maxChars = value * 2;
			this.addEventListener(Event.CHANGE, onChangeChars, false, 100);
			this.tabIndex = 100;
		}

		public function number(min : Number, max : Number, precision : int = 0) : void {
			this.min = min;
			this.max = max;
			this.precision = precision;
			this.addEventListener(Event.CHANGE, onChangeNumber, false, 100);
			this.tabIndex = 100;
		}

		private var emptyStr : String;
		private var emptyFormat : TextFormat;

		public function empty(str : String, color : int = 0x8B8B8B) : void {
			emptyStr = str;
			emptyFormat = new TextFormat(format.font, format.size, color);
			super.text = emptyStr;
			this.setTextFormat(emptyFormat);
			addEventListener(FocusEvent.FOCUS_OUT, onTxtOut);
			addEventListener(FocusEvent.FOCUS_IN, onTxtIn);
		}

		private function onTxtOut(event : FocusEvent) : void {
			if (super.text == "" ) {
				super.text = emptyStr;
				this.setTextFormat(emptyFormat);
			}
		}

		private function onTxtIn(event : FocusEvent) : void {
			if (super.text == emptyStr) {
				super.text = "";
				this.setTextFormat(format);
			}
		}

		public override function get text() : String {
			return super.text == emptyStr ? "" : super.text;
		}

		private function onChangeChars(event : Event) : void {
			// text = text.replace(/(^\s+)|(\s+?)/g, '');
			while (length > super.maxChars / 2) {
				text = text.substr(0, text.length - 1);
			}
			this.setTextFormat(format);
		}

		private var min : Number;
		private var max : Number;
		private var precision : int;

		private function onChangeNumber(event : Event) : void {
			text = text.replace(/(^\s+)|(\s+?)/g, '');
			if (text == "" || text == "-") return;
			var index : int = text.indexOf(".") + 1;
			if (index > 0 && index + precision < text.length) {
				text = text.substring(0, index + precision);
			}
			var num : Number = Number(text);
			if (isNaN(num) || num < min) {
				text = min.toString();
			} else if (num > max) {
				text = max.toString();
			}
		}

		public override function get length() : int {
			return text.replace(/[^\x00-\xff]/g, "xx").length;
		}
	}
}
