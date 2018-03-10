package ge.gpu.display {
	import flash.geom.Rectangle;
	
	import ge.utils.Tween;
	
	public class GameProgress extends GameObject {
		private var gp : GameClipSprite;
		private var w : Number;
		private var rect : Rectangle;
		private var ber : Image;
		private var max:Number;
		private var _value:Number;
		
		
		public function GameProgress(c : GameObject, x : int, y : int, img : int) {
			this.x = x;
			this.y = y;
			c.addChild(this);
			
			gp = new GameClipSprite();
			this.addChild(gp);
			ber = new Image(gp, 0, 0, img);
			w = ber.width;
			rect = new Rectangle(0, 0, ber.width, ber.height);
		}
		private var tween:Tween;
		public function Set(max : Number, value : Number,time:Number=0,callback:Function=null) : void {
			this.max=max;
			if(time>0){
				if(tween==null){
					tween=new Tween(this);
				}
				tween.start(time,{value:value},null,callback);
			}else{
				this.value=value;
			}
		}
		
		public function get value():Number{
			return _value;
		}
		
		public function set value(value:Number):void{
			_value = value;
			var sum : Number = value / max * w
			rect.width = sum < 1.1 && sum > 0 ? 1.1 : sum;
			gp.scrollRect = rect;
		}
	}
}
