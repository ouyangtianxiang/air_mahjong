package ge.net.view
{
	import flash.display.Sprite;
	
	public class Head extends Sprite{
		public var array:Vector.<Label>=new Vector.<Label>(DataView.colsCount);
		private var dataView:DataView;
		public function Head(dataView:DataView,x:int,y:int){
			this.x=x;
			this.y=y;
			dataView.addChild(this);
			this.dataView=dataView;
			
			for(var i:int=0;i<DataView.colsCount;i++){
				array[i]=new Label(this,100*i,0);
			}
		}
		
		public function refresh(index:int):void{
			for(var i:int=0;i<DataView.colsCount;i++){
				array[i].value(dataView.names[i+index]);
			}
		}
	}
}