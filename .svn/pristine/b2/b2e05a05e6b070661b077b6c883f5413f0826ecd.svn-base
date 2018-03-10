package ge.net.view {
	import flash.display.DisplayObjectContainer;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**文本
	 * @author txoy
	 */
	public class VText extends TextField {
		public static var FONT:String="Arial";
		private var format : TextFormat;

		public function VText(c : DisplayObjectContainer, text : String = "", x : Number = 0, y : Number = 0, color : uint = 0, size : uint = 12, w : uint = 0, h : uint = 0, strokeColor : * = null, bold : Boolean = false) {
			if (c != null) {
				c.addChild(this);
			}
			this.x = x;
			this.y = y;
			this.textColor = color;
			format = new TextFormat(FONT, size, color, bold);
			this.text = text;

			selectable = false;
			if (w > 0) {
				this.width = w;
			}
			if (h > 0) {
				height = h;
				multiline = true;
				wordWrap = true;
				autoSize = TextFieldAutoSize.NONE;
			} else {
				autoSize = TextFieldAutoSize.LEFT;
			}
			if (strokeColor) {
				this.filters = [new GlowFilter(strokeColor, 1, 2, 2, 10, 1)];
			}
			cacheAsBitmap = true;
		}

		public function set align(value : String) : void {
			format.align = value;
			this.setTextFormat(format);
		}

		public function set color(value : Object) : void {
			format.color = value;
			this.setTextFormat(format);
		}
		
		public function get color():Object{
			return format.color;
		}
	}
}
