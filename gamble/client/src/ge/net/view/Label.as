package ge.net.view
{
	import flash.display.Sprite;
	
	
	public class Label extends Sprite
	{
		private var txt:VText;
		public function Label(head:Head,x:int,y:int){
			this.x=x;
			this.y=y;
			head.addChild(this);
			
			txt = new VText(this, "", 0, 0, 0, 12, 100, 19);
			txt.doubleClickEnabled = true;
			txt.border = true;
			txt.borderColor = 0xaca899;
			txt.background = true;
			txt.backgroundColor = 0xcbc9bc;
		}
		
		public function value(v:String):void{
			if(v){
				txt.text=v;
				visible=true;
			}else{
				visible=false;
			}
		}
	}
}