package ge.gpu.display {
	import flash.display.BitmapData;
	
	import ge.gpu.texture.BitmapTexture;
	
	public class PureColor extends Quad {
		private static var obj : Object = {};
		
		private static function getTexture(color : uint) : BitmapTexture {
			var _texture : BitmapTexture = obj[color];
			if (_texture == null) {
				_texture = new BitmapTexture();
				_texture.data = new BitmapData(1, 1, true, color);
				obj[color] = _texture;
			}
			return _texture;
		}
		
		public function PureColor(c : GameObject, x : Number, y : Number, w : Number, h : Number, color : uint) {
			this.x = x;
			this.y = y;
			if(c){
				c.addChild(this);
			}
			this.scaleX = w;
			this.scaleY = h;
			this.texture = getTexture(color);
		}
	}
}
