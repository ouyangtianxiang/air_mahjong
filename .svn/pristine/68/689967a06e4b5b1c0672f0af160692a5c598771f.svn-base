package ge.net.view
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.system.System;
	
	import ge.utils.tick.ITick;
	import ge.utils.tick.Tick;
	
	public class FPS extends Sprite implements ITick{
		private static var _it : FPS;
		
		public static function get it() : FPS {
			if (_it == null) {
				_it = new FPS();
			}
			return _it;
		}
		
		private var txt:VText;
		public function FPS(){
			new Btn(this,1,1,18,18,"+",0x55AA55).addEventListener(MouseEvent.CLICK, onClick1);
			new Btn(this,20,1,18,18, "-",0x55AA55).addEventListener(MouseEvent.CLICK, onClick2);
			txt = new VText(this, " ", 40, 0, 0xFFFF00,12,0,0,1);
		}
		
		public function onClick1(event:MouseEvent):void{
			stage.frameRate++;
		}
		
		public function onClick2(event:MouseEvent):void{
			stage.frameRate--;
		}
		
		private const N:int=5;
		private var i:int;
		private var dt:Number=0;
		public function run(dt:Number):void{
			i++;
			this.dt+=dt;
			if(i==N){
				txt.text = "FPS：" + Math.round(1000/this.dt*N) + "/" + this.stage.frameRate + "   Memory：" + int(System.totalMemory / 1024 / 1024) + "M";
				i=0;
				this.dt=0;
			}
		}
		
		public function show(c:DisplayObjectContainer,x:int=0,y:int=0):void{
			this.x=x;
			this.y=y;
			c.addChild(this);
			Tick.addTick(this);
		}
		
		public function hide():void{
			if(this.parent){
				parent.removeChild(this);
			}
			Tick.removeTick(this);
		}
	}
}