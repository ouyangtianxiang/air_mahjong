package game {
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	import game.utils.Music;
	
	import ge.global.Main;
	import ge.gpu.display.Game3D;
	
	
	/**
	 * @author txoy
	 */
	[SWF(backgroundColor="0x000000", frameRate="30")]
	public class GameMain extends Main {
		private var game3D:Game3D;
		
		public function GameMain() {
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, onActivaie);
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, onDeactivate);
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE; //保持常亮 一直唤醒的状态
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			var manufacturer:String=Capabilities.manufacturer.toLowerCase();
			
			super(init);
		}
		
		protected function onActivaie(event : Event) : void {
			Music.it.onActivaie();
			if(game3D){
				game3D.onActivaie();
			}
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE; //保持常亮 一直唤醒的状态
		}
		
		protected function onDeactivate(event : Event) : void {
			Music.it.onDeactivate();
			if(game3D){
				game3D.onDeactivate();
			}
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.NORMAL;  //回复正常
		}
		
		private var _width:Number=0;
		private var _height:Number=0;
		public override function get GameWidth() : int {
			return _width;
		}
		
		public override function get GameHeight() : int {
			return _height;
		}
		
		protected function onKeyDown(event : KeyboardEvent) : void {
			if (event.keyCode == Keyboard.BACK) {
				NativeApplication.nativeApplication.exit();
				event.preventDefault();
			}
		}
		
		private function init():void{
			_width=Math.max(stage.fullScreenWidth,stage.fullScreenHeight);
			_height=Math.min(stage.fullScreenWidth,stage.fullScreenHeight);
			new Config(Open);
		}
		
		/**
		 * 加载配置回调
		 */
		private function Open() : void {
			game3D=new Game3D(stage, Game);
		}
	}
}


