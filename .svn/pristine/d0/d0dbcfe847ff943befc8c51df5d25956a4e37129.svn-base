package ge.net.view
{
	import flash.display.Sprite;
	import flash.filters.BevelFilter;
	
	
	public class Btn extends Sprite
	{
		private static var filter:Array=[new BevelFilter(1)];
		public var text:VText;
		public function Btn(c:Sprite,x:int,y:int,w:int,h:int,txt:String,color:uint){
			this.x=x;
			this.y=y;
			if(c){
				c.addChild(this);
			}
			
			text = new VText(this, txt, 0, 0, 0xFFFFFF, 12, w, h);
			text.filters=filter;
			text.background = true;
			text.backgroundColor = color;
			text.mouseEnabled=false;
			this.useHandCursor=true;
			this.buttonMode=true;
		}
		public function remove():void{
			if(this.parent){
				this.parent.removeChild(this);
			}
		}
	}
}