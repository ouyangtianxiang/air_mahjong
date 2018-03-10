package ge.gpu.display {
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import ge.utils.Tween;
	
	public class DynamicProgress extends GameObject {
		private var gp : GameClipSprite;
		private var w : Number;
		private var rect : Rectangle;
		private var ber : Image;
		private var tween : Tween;
		
		public function DynamicProgress(c : GameObject, x : int, y : int, img : int, bg : int = 0, offsetX : int = 0, offsetY : int = 0, left : Boolean = true) {
			if (bg) {
				new Image(this, 0, 0, bg);
			}
			var floorImg : Image = new Image(this, 0, 0, 4001);
			floorImg.setColor(0xFFFF00, true);
			
			tween = new Tween(floorImg);
			
			gp = new GameClipSprite();
			gp.x = offsetX;
			gp.y = offsetY;
			floorImg.x = gp.x;
			floorImg.y = gp.y;
			this.addChild(gp);
			ber = new Image(gp, 0, 0, img);
			w = ber.width;
			rect = new Rectangle(0, 0, ber.width, ber.height);
			this.x = x;
			this.y = y;
			c.addChild(this);
			if (!left) {
				gp.scaleX = -1;
				ber.scaleX = -1;
				ber.x = rect.width;
			}
		}
		private var t : uint;
		
		public function Set(max : Number, value : Number) : void {
			var sum : Number = value / max * w
			rect.width = sum < 1.1 && sum > 0 ? 1.1 : sum;
			gp.scrollRect = rect;
			clearTimeout(t);
			t = setTimeout(startScale, 200, max, value);
		}
		
		private function startScale(max : Number, value : Number) : void {
			var sum : Number = value / max <= 0 ? 0.0001 : value / max;
			tween.start(1000, {scaleX:sum});
		}
	}
}

