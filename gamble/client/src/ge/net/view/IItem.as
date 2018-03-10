package ge.net.view
{
	import flash.display.Sprite;
	import flash.text.TextFormatAlign;
	
	import ge.net.Bean;
	
	public class IItem extends Sprite{
		private var txt1:VText;
		private var txt2:VInput;
		public function IItem(c:Sprite,x:int,y:int){
			this.x=x;
			this.y=y;
			c.addChild(this);
			
			txt1 = new VText(this, "NULL", 0, 0, 0, 12, 120, 18);
			txt1.align=TextFormatAlign.RIGHT;
			
			txt2 = new VInput(this, "000", 130, 0, 100);
			txt2.border = true;
			txt2.borderColor = 0xd4d0c8;
			txt2.background = true;
			txt2.backgroundColor =0xf4f4f4;
		}
		
		public function data(label:String,o:Bean):void{
			txt1.text=label+"：";
			txt2.textColor=0;
			if(label!=null){
				name=label;
				if(o){
					txt2.text=o.hasOwnProperty(label)?o[label]:"0";
				}
				visible=true;
			}
		}
		public function get value():String{
			return txt2.text;
		}
		public function error():void{
			txt2.textColor=0xFF0000;
		}
	}
}