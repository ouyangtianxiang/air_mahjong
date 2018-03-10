package ge.net.view {
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import ge.global.GM;
	import ge.global.Url;
	
	/**
	 * @author tianxiang.ouyang
	 */
	public class View extends Sprite {
		private static var _it:View;
		public static function get it() : View{
			if(_it==null){
				_it=new View();
			}
			return _it;
		}
		
		public function View() {
			this.graphics.beginFill(0x6658e6, .8);
			this.graphics.drawRect(0, 0, 1000, 20);
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			new Btn(this,1,1,60,18,"Debugger",0xFF0000).addEventListener(MouseEvent.CLICK, onClickDebugger);
			new Btn(this,980,1,18,18,"X",0xFF0000).addEventListener(MouseEvent.CLICK, onClickExit);
		}
		
		private function onClickDebugger(event : MouseEvent) : void {
			var loader:Loader=new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
			loader.load(new URLRequest(Url+"Debugger.swf"));
			(event.target as Btn).remove();
		}
		
		private function onComplete(event:Event):void{
			var loader:LoaderInfo=event.target as LoaderInfo;
			new Btn(this,1,1,90,18,"theMiner",0xFF0000).addEventListener(MouseEvent.CLICK, function(e1:MouseEvent):void{
				loader.content["theMiner"](GM);
				(e1.target as Btn).remove();
			});
			new Btn(this,100,1,90,18,"monsterDebugger",0xFF0000).addEventListener(MouseEvent.CLICK, function(e2:MouseEvent):void{
				loader.content["monsterDebugger"](GM);
				(e2.target as Btn).remove();
			});
		}
		
		private function onMouseDown(event:MouseEvent):void{
			if(event.target==this){
				this.startDrag();
				stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			}
		}
		
		private function onMouseUp(event:MouseEvent):void{
			this.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		
		private function onClickExit(event : MouseEvent) : void {
			View.it.hide();
		}
		
		public function onKeyDown() : void {
			if(stage){
				hide();
			}else{
				show();
			}
		}
		
		public function show():void{
			FPS.it.show(this,320,0);
			TableView.it.show(this,0,20);
			GM.addChild(this);
		}
		
		public function hide() : void {
			stage.focus = stage;
			if(Insert.it.stage){
				Insert.it.hide();
				return;
			}
			if (DataView.it.stage) {
				DataView.it.hide();
				return;
			}
			if(TableView.it.stage){
				TableView.it.hide();
				return;
			}
			if(FPS.it.stage){
				FPS.it.hide();
			}
			if(parent){
				parent.removeChild(this);
			}
		}
	}
}
