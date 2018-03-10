package ge.gpu.texture {
	import flash.display.BitmapData;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import game.font.FONT;
	
	import ge.global.GM;
	
	public class FontTexture extends BitmapTexture {
		public static const RES : Object = new Object();
		
		private static var filter : Array = [new GlowFilter(0x000000, 1, 2, 2, 4, BitmapFilterQuality.MEDIUM)];
		private  var format : TextFormat = new TextFormat(FONT?FONT.fontName:"Microsoft YaHei", 30, 0xFFFFFF, true);
		private static var textField : TextField;
		
		public function FontTexture(char : String) {
			if (textField == null) {
				textField = new TextField();
				textField.filters = filter;
				textField.autoSize = TextFieldAutoSize.LEFT;
				GM.addChild(textField);
				textField.visible = false;
			}
			textField.text = char;
			textField.setTextFormat(format);
			if (FONT && FONT.hasGlyphs(char)) {
				textField.gridFitType = GridFitType.SUBPIXEL;
				textField.embedFonts = true;
				textField.antiAliasType = AntiAliasType.ADVANCED;
			} else {
				textField.gridFitType = GridFitType.NONE;
				textField.embedFonts = false;
				textField.antiAliasType = AntiAliasType.NORMAL;
			}
			var rect : Rectangle = textField.getCharBoundaries(0);
			if (rect == null) {
				rect = new Rectangle(0, 0, 1, 1);
			}
			var bd : BitmapData = new BitmapData(rect.width, rect.height, true, 0x00000000);
			bd.draw(textField, new Matrix(1, 0, 0, 1, -rect.x + 1, -rect.y));
			data = bd;
			init();
			RES[char] = this;
		}
		
		
		public static function Font(char : String) : BaseTexture {
			var texture : BaseTexture = RES[char];
			if (texture == null) {
				texture = new FontTexture(char);
			}
			return texture;
		}
	}
}
