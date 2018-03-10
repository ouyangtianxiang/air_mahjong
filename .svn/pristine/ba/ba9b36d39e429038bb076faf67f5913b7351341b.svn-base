package ge.net.view
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import ge.net.Bean;
	
	public class Row extends Sprite	{
		
		public static const btn1:Btn=new Btn(null,0,0,12,18,"X",0xFF0000);
		public var array:Vector.<Field>=new Vector.<Field>(DataView.colsCount);
		private var dataView:DataView;
		public function Row(dataView:DataView,x:int,y:int,index:int){
			this.x=x;
			this.y=y;
			dataView.addChild(this);
			this.dataView=dataView;
			
			for(var i:int=0;i<DataView.colsCount;i++){
				array[i]=new Field(this,100*i,0,dataView,index);
			}
			
			this.addEventListener(MouseEvent.CLICK,onClick);
			
		}
		
		private function onClick(event:MouseEvent):void{
			if(btn1.contains(event.target as DisplayObject)){
				dataView.del(o);
			}else{
				this.addChild(btn1);
			}
		}
		
		private var o:Bean;
		public function Obj(o:Bean):void{
			this.o=o;
			visible=o!=null;
		}
		
		public function refresh(index:int):void{
			if(o){
				for(var i:int=0;i<DataView.colsCount;i++){
					array[i].value(o,dataView.names[i+index]);
				}
			}
		}
	}
}