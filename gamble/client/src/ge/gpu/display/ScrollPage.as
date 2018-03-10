package ge.gpu.display{
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import ge.events.GameEvent;
	import ge.global.GM;
	import ge.utils.Tween;
	
	public class ScrollPage extends GameClipSprite{
		private var items:Vector.<IPage>=new Vector.<IPage>();
		protected var bg:PureColor;
		protected var space:GameObject;
		
		private var maxSize:int;
		private var w:int;
		private var h:int;
		private var img:int;
		public function ScrollPage(c:GameObject,x:int,y:int,w:int,h:int,img:int,C:Class){
			this.x=x;
			this.y=y;
			c.addChild(this);
			this.w=w;
			this.h=h;
			this.img=img;
			
			this.mouseEnabled=true;
			space=new GameObject();
			scrollRect=new Rectangle(0,0,w,h);
			bg=new PureColor(null,0,0,w,h,GM.Debug?0x99FF0000:0x00FF0000);
			bg.mouseEnabled=true;
			super.addChild(bg);
			space.mouseEnabled=true;
			super.addChild(space);
			for(var i:int=0;i<3;i++){
				var item:IPage=new C();
				item.x=i*w;
				space.addChild(item);
				items.push(item);
			}
			
			this.addEventListener(GameEvent.DOWN,onGameDown);
			this.addEventListener(GameEvent.UP,onGameUp);
			tween=new Tween(space);
		}
		
		private var sp:int;
		protected var v:Number;
		protected var _x:int;
		private var time:Number;
		private var tween:Tween;
		private var array:Array;
		protected function onGameDown(go:GameObject):void{
			stage.addEventListener(GameEvent.MOVE,onGameMove);
			_x=go.touchX/absScaleX;
			v=0;
			if(tween.isPlaying){
				onTween();
				tween.stop();
			}
			time=0;
		}
		
		protected function onGameMove(event:Event):void{
			if(GameEvent.TouchID(event)==touchID){
				var x:int=GameEvent.StageX(event)/absScaleX;
				v=_x-x;
				space.x-= v;
				_x=x;
				event["updateAfterEvent"]();
				time=getTimer();
			}
		}
		
		protected function onGameUp(go:GameObject):void{
			GM.stage.removeEventListener(GameEvent.MOVE,onGameMove);
			var m:int=Math.floor(space.x/w)*w;
			if(space.x!=m){
				if(time==0 || getTimer()-time>100){
					if(Math.abs(space.x%w)<w/2){
						m+=w;
					}
				}else{
					if(v<0){
						m+=w;
					}
				}
				var t:Number=Math.abs(space.x-m)*2;
				tween.start(t,{x:m},null,onTween);
			}
		}
		
		private function onTween():void{
			for each (var item:IPage in items){
				var _x:int=item.x+space.x;
				if(_x==0){
					select(item.index);
				}else if(_x>w){
					fill(item,item.x-w*3,item.index-3);
				}else if(_x<-w){
					fill(item,item.x+w*3,item.index+3);
				}
			}
		}
		
		public function data(array:Array,def:int=0):void{
			this.array=array;
			createImg(array.length);
			space.x=0;
			fill(items[0],-w,def-1);
			fill(items[1],0,def);
			fill(items[2],w,def+1);
			select(def);
		}
		
		private function fill(item:IPage,x:int,index:int):void{
			item.x=x;
			item.index=index;
			item.data(array[dataIndex(index)]);
		}
		
		public function dataIndex(index:int):int{
			var i:int=index%array.length;
			if(i<0){
				i=array.length+i;
			}
			return i;
		}
		
		private var imgs:Vector.<CheckBox>=new Vector.<CheckBox>;
		private function createImg(num:int):void{
			if(imgs.length!=num){
				while(imgs.length<num){
					imgs.push(new CheckBox(this,0,0,img));
				}
				while(imgs.length>num){
					imgs.pop().remove();
				}
				for(var i:int=0;i<imgs.length;i++){
					var g:CheckBox=imgs[i];
					g.x=(w-num*g.width)/2+i*g.width;
					g.y=h-g.height;
				}
			}
		}
		
		private function select(index:int):void{
			var _index:int=dataIndex(index)
			for(var i:int=0;i<imgs.length;i++){
				imgs[i].select=i==_index;
			}
			_obj=array[_index];
			dispatchEvent(new Event(Event.SELECT));
		}
		
		private var _obj:*;
		public function get obj():*{
			return _obj;
		}
	}
}