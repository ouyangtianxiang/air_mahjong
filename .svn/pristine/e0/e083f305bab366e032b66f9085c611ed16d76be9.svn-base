package ge.gpu.display {
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	
	
	public class GameProgressMC extends GameObject {
		private var gp : GameClipSprite;
		private var w : Number;
		private var rect : Rectangle;
		private var ber : MC;
		
		public function GameProgressMC(c : GameObject, x : int, y : int, url : String, hieght : Number = 0, width : Number = 0, bg : int = 0, offsetX : int = 0, offsetY : int = 0, left : Boolean = true) {
			if (bg) {
				new Image(this, 0, 0, bg);
			}
			gp = new GameClipSprite();
			gp.x = offsetX;
			gp.y = offsetY;
			this.addChild(gp);
			ber = new MC(gp, width / 2, hieght / 2);
			ber.load(url);
			c.addChild(this);
			ber.play();
			w = width;
			rect = new Rectangle(0, 0, width, hieght);
			this.x = x;
			this.y = y;
			
			if (!left) {
				gp.scaleX = -1;
				ber.scaleX = -1;
				ber.x = width;
			}
		}
		
		
		public function Set(max : Number, value : Number) : void {
			var sum : Number = value / max * w
			rect.width = sum < 1.1 && sum > 0 ? 1.1 : sum;
			gp.scrollRect = rect;
		}
	}
}

