package ge.global {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.utils.getTimer;
	
	import ge.net.view.View;
	
	/**
	 * @author Administrator
	 */
	public class Main extends Sprite {
		private var added:Function;
		private var debug:Boolean;
		public function Main(added:Function,debug:Boolean=false) {
			GM = this;
			this.added=added;
			this.debug=debug;
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		private function onAdded(event:Event):void{
			stage.frameRate = 30;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.showDefaultContextMenu = false;
			stage.stageFocusRect = false;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(Event.REMOVED, onRemoveStage);
			added();
		}
		
		private function onRemoveStage(event : Event) : void {
			if (stage.focus == null || stage.focus.stage == null) {
				stage.focus = this;
				return;
			}
		}
		
		private const PWD:String="t";
		private var pwd:String;
		private var t:int;
		private function onKeyDown(event : KeyboardEvent) : void {
			if(event.shiftKey){
				var t:int=getTimer();
				if(t>this.t+2000){
					pwd="";
				}
				this.t=t;
				pwd+=String.fromCharCode(event.keyCode).toLowerCase();
				if (pwd==PWD) {
					View.it.onKeyDown();
				}
			}
		}
		
		public function get GameWidth() : int {
			return stage.stageWidth;
		}
		
		public function get GameHeight() : int {
			return stage.stageHeight;
		}
		
		public function get Debug() : Boolean{
			return debug;
		}
	}
}
