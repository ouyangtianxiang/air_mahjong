package ge.gpu.display{
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import ge.events.GameEvent;
	import ge.global.GM;
	import ge.utils.tick.ITick;
	import ge.utils.tick.Tick;
	
	public class Scroll extends GameClipSprite implements ITick{
		protected var bg:PureColor;
		private var _maxSize:int;
		
		public function get maxSize():int{
			return _maxSize;
		}
		
		public function set maxSize(value:int):void{
			_maxSize = value;
		}
		
		protected var vertical:Boolean;
		protected var space:GameObject;
		/**
		 * @param c:parent
		 * @param x:x
		 * @param y:y
		 */
		public function Scroll(c:GameObject,x:int,y:int,vertical:Boolean,_w:int,_h:int){
			this.x=x;
			this.y=y;
			c.addChild(this);
			this.scrollRect=new Rectangle(0,0,_w,_h);
			this.mouseEnabled=true;
			this.vertical=vertical;
			bg=new PureColor(null,0,0,_w,_h,GM.Debug?0x99FF0000:0x00FF0000);
			bg.mouseEnabled=true;
			super.addChild(bg);
			space=new GameObject();
			space.mouseEnabled=true;
			super.addChild(space);
			
			this.addEventListener(GameEvent.DOWN,onGameDown);
			this.addEventListener(GameEvent.UP,onGameUp);
		}
		
		private var _event:Event;
		internal override function dispatch(event:Event):Boolean{
			var me:Boolean=mouseEnabled;
			if(event.type==GameEvent.UP){
				if(!GameEvent.point(event,_event)){
					mouseEnabled=false;
				}
			}else{
				_event=event;
			}
			var dis:Boolean=super.dispatch(event);
			mouseEnabled=me;
			return dis;
		}
		
		protected var v:Number;
		protected var m:int;
		protected function onGameDown(go:GameObject):void{
			stage.addEventListener(GameEvent.MOVE,onGameMove);
			m=vertical?go.touchY/absScaleY:go.touchX/absScaleX;
			stop();
		}
		
		protected function onGameMove(event:Event):void{
			if(GameEvent.TouchID(event)==touchID){
				var _m:int=vertical?GameEvent.StageY(event)/absScaleY:GameEvent.StageX(event)/absScaleX;
				v = m-_m;
				m=_m;
				move();
				event["updateAfterEvent"]();
			}
		}
		
		protected function onGameUp(go:GameObject):void{
			GM.stage.removeEventListener(GameEvent.MOVE,onGameMove);
			if(int(v)!=0){
				Tick.addTick(this);
			}
		}
		
		protected function move():void{
			if(vertical){
				position=Math.max(0,Math.min(position+v,_maxSize-scrollRect.height));
			}else{
				position=Math.max(0,Math.min(position+v,_maxSize-scrollRect.width));
			}
		}
		
		public function run(dt : Number):void{
			var t:int=position;
			move();
			v*=0.9;
			if(t==position || int(v)==0){
				stop();
			}
		}
		
		protected function stop():void{
			v=0;
			Tick.removeTick(this);
		}
		
		
		protected function set position(value:Number):void{
			if(vertical){
				space.y=-value;
			}else{
				space.x=-value;
			}
		}
		
		protected function get position():Number{
			return vertical?-space.y:-space.x;
		}
		
		public function get value():Number{
			return position/(_maxSize-(vertical?scrollRect.height:scrollRect.width));
		}
		
		public function set value(value:Number):void{
			position=value*(_maxSize-(vertical?scrollRect.height:scrollRect.width));
		}
	}
}