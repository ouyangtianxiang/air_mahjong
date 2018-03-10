package ge.gpu.display{
	
	
	public class ScrollView extends Scroll{
		private var items:Array=[];
		private var itemNum:int;
		private var num:int;
		private var array:Array;
		private var h:int;
		private var w:int;
		/**
		 * @param c:parent
		 * @param x:x
		 * @param y:y
		 * @param w:item宽
		 * @param h:item高
		 * @param cols:列数
		 * @param height:高
		 * @param C:Item类
		 */
		public function ScrollView(c:GameObject,x:int,y:int,w:int,h:int,num:int,len:int,C:Class,vertical:Boolean=true,callback:Function=null){
			var _w:int=vertical?w*num:len;
			var _h:int=vertical?len:h*num;
			super(c,x,y,vertical,_w,_h);
			this.h=h;
			this.w=w;
			this.num=num;
			if(vertical){
				this.itemNum=num*(Math.ceil(len/h)+1);
			}else{
				this.itemNum=num*(Math.ceil(len/w)+1);
			}
			for(var i:int=0;i<itemNum;i++){
				var item:IScroll=new C();
				item.callback=callback;
				item._width=w;
				item._height=h;
				item.init();
				space.addChild(item);
				items.push(item);
			}
		}
		
		protected override function move():void{
			super.move();
			if(v>0){
				toEnd();
			}else if(v<0){
				toBegin();
			}
		}
		
		private function isBegin(item:IScroll):Boolean{
			return vertical?item.y>-space.y+scrollRect.height:item.x>-space.x+scrollRect.width;
		}
		
		private function toBegin():void{
			var item:IScroll=items[itemNum-1];
			if(isBegin(item)){
				if(item.index-itemNum>=0){
					item._index-=itemNum;
					pos(item);
					items.unshift(items.pop());
					toBegin();
				}
			}
		}
		
		private function isEnd(item:IScroll):Boolean{
			return vertical?item.y+h<-space.y:item.x+w<-space.x;
		}
		
		private function toEnd():void{
			var item:IScroll=items[0];
			if(isEnd(item)){
				item._index+=itemNum;
				pos(item);
				items.push(items.shift());
				toEnd();
			}
		}
		
		public function data(array:Array):void{
			this.array=array;
			maxSize=Math.ceil(Math.max(1,array.length)/num)*(vertical?h:w);
			for(var i:int=0;i<itemNum;i++){
				var item:IScroll=items[i];
				item._index=i;
				pos(item);
			}
			stop();
			position=0;
		}
		
		public function update():void{
			for each (var item:IScroll in items){
				item.data(array[item.index]);
			}
		}
		
		private function pos(item:IScroll):void{
			item.data(array[item.index]);
			if(vertical){
				item.x=item.index%num*w;
				item.y=int(item.index/num)*h;
			}else{
				item.x=int(item.index/num)*w;
				item.y=item.index%num*h;
			}
		}
		
		public function select(index:int):IScroll{
			v=int(index/num)*(vertical?h:w)-position;
			move();
			for each (var item:IScroll in items){
				if(item.index==index){
					return item;
				}
			}
			return null;
		}
		
		public override function set value(value:Number):void{
			v=value-super.value;
			super.value=value;
			move();
		}
	}
}