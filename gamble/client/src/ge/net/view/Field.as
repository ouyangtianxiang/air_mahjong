package ge.net.view
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextFieldType;
	
	import ge.net.Bean;
	
	public class Field extends Sprite{
		public static const btn1:Btn=new Btn(null,76,0,12,18,"+",0x999999);
		public static const btn2:Btn=new Btn(null,88,0,12,18,"-",0x999999);
		private var txt:VText;
		private var dataView:DataView;
		public function Field(c:Sprite,x:int,y:int,dataView:DataView,index:int){
			this.x=x;
			this.y=y;
			c.addChild(this);
			this.dataView=dataView;
			
			txt = new VText(this, "", 0, 0, 0, 12, 100, 18);
			txt.doubleClickEnabled = true;
			txt.border = true;
			txt.borderColor = 0xd4d0c8;
			txt.background = true;
			txt.backgroundColor = index % 2 == 0 ? 0xf4f4f4 : 0xffffff;
			
			this.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			this.addEventListener(MouseEvent.CLICK,onClick);
		}
		
		private function onClick(event:MouseEvent):void{
			var n:int=0
			if(btn1.contains(event.target as DisplayObject)){
				n=1;
			}
			if(btn2.contains(event.target as DisplayObject)){
				n=-1;
			}
			if(event.shiftKey){
				n*=10;
			}
			if(event.ctrlKey){
				n*=100;
			}
			if(event.altKey){
				n*=10000;
			}
			if(n!=0){
				update(n);
			}else{
				this.addChild(btn1);
				this.addChild(btn2);
			}
		}
		
		private function update(n:Number):void{
			if(!dataView.update(o,fieldName,n)){
				o[fieldName]+=n;
				value(o,fieldName);
			}
		}
		
		
		private function onDoubleClick(event : MouseEvent) : void {
			txt.selectable = true;
			txt.setSelection(0, txt.length);
			txt.type=TextFieldType.INPUT;
			txt.addEventListener(FocusEvent.FOCUS_OUT,onChange);
		}
		
		private function onChange(event:Event):void{
			txt.selectable = false;
			txt.removeEventListener(FocusEvent.FOCUS_OUT,onChange);
			txt.type=TextFieldType.DYNAMIC;
			var v:Number=Number(txt.text)
			if(o[fieldName] is Number && !isNaN(v) &&o[fieldName]!=v){
				update(v-o[fieldName]);
			}
		}
		
		private var o:Bean;
		private var fieldName:String;
		
		public function value(o:Bean,name:String):void{
			this.o=o;
			this.fieldName=name;
			if(name){
				txt.text=o[name];
				visible=true;
			}else{
				visible=false;
			}
		}
	}
}