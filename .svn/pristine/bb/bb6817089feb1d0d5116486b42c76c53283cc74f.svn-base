package game.modules.nanchangmahjong.front
{
	import ge.gpu.display.GameObject;
	import ge.gpu.display.Image;
	
	public class Brand extends Image
	{
		public static const OPPOSITE:int=0;
		public static const SELF:int=1;
		public static const LEFT:int=2;
		public static const RIGHT:int=3;
		public function Brand(c:GameObject, x:int, y:int,dir:int,open:Boolean,value:int,my:Boolean=false)
		{
			super(c, x, y);
			anchor(0.5,0.5);
			var vimg:Image=new Image(this,0,0,"mahjong."+value);
			vimg.visible=open || dir==SELF;
			switch(dir)
			{
				case OPPOSITE:
					if(open){
						this.img="mahjong.123";
						vimg.rotation=180;
						vimg.anchor(0.5,0.5);
						vimg.scale=0.5;
					}else{
						this.img="mahjong.121";
					}
					break;
				case LEFT:
					if(open){
						this.img="mahjong.133";
						vimg.scale=0.5;
						vimg.rotation=270;
						vimg.anchor(0.5,0.5);
					}else{
						this.img="mahjong.131";
					}
					break;
				case RIGHT:
					if(open){
						this.img="mahjong.133";
						vimg.scale=0.5;
						vimg.rotation=90;
						vimg.anchor(0.5,0.5);
					}else{
						this.img="mahjong.141";
					}
					break;
				case SELF:
					if(open){
						if(my){
							this.img="mahjong.113";
							vimg.anchor(0.5,0.5);
							vimg.scale=0.8;
						}else{
							this.img="mahjong.123";
							vimg.anchor(0.5,0.5);
							vimg.scale=0.5;
						}
					}else{
						this.img="mahjong.111";
						vimg.anchor(0.5,0.5);
						vimg.scale=0.95;
					}
					break;
			}
			
		}
	}
}