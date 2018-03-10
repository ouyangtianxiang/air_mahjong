package ge.gpu.display {
	import ge.gpu.texture.UITexture;
	
	public class GameNumber extends GameObject {
		public static const LEFT : int = 0;
		public static const CENTER : int = 1;
		public static const RIGHT : int = 2;
		private var w : int;
		private var h : int;
		private var align : int;
		private var interval : Number;
		
		public function GameNumber(container : GameObject, x : int, y : int, img : String, value : int, align : int = 0, interval : Number = 0.8) {
			this.x = x;
			this.y = y;
			container.addChild(this);
			
			this.align = align;
			this.interval = interval;
			
			image = img;
			this.value = value;
		
		}
		
		public function set image(img : String) : void {
			list = UITexture.UI( img, 1, 10);
			w = list[0].width;
			h = list[0].height;
		}
		
		private var list : Array;
		
		private var _value : Number;
		
		public function get value() : Number {
			return _value;
		}
		
		private var array : Array = [];
		
		public function set value(v : Number) : void {
			_value = v;
			var str : String = int(v).toString();
			var len : int = str.length;
			var al : int = str.length * w * interval + w * (1 - interval);
			al = [0, -al / 2, -al][align];
			var maxlen : int = Math.max(array.length, len);
			for (var i : int = 0; i < maxlen; i++) {
				var quad : Quad = array[i];
				if (i < len) {
					if (quad == null) {
						quad = new Quad();
						array[i] = quad;
					}
					var n : Number = int(str.charAt(i));
					var sx : Number = w * i * interval + al;
					quad.texture = list[n];
					quad.x = sx;
					this.addChild(quad);
				} else if (quad) {
					quad.remove();
				}
			}
		}
	}
}
