package game.modules.login{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	import game.Config;
	import game.modules.hall.ModuleHall;
	import game.utils.Protocol;
	
	import ge.global.SO;
	import ge.net.Buffer;
	import ge.net.IM;
	import ge.net.type.short;
	
	public class Login{
		public static var it:Login;
		private var im:IM;
		private var reconnent:int = 0;
		
		public function Login(){
			it = this;
			connect();
		}
		
		private function connect():void {
			im = new IM(Config.xml["ip"], Config.xml["port"]);
			im.addEventListener(Event.CONNECT, onConnect);
			im.addEventListener(IOErrorEvent.IO_ERROR, onClose);
			im.addEventListener(Event.CLOSE, onClose);
		}
		
		private function onConnect(event:Event):void {
			var passid:String=SO.data["passID"];
			IM.Call(Protocol.LOGIN,onLogin,"aaa",22,passid,new short(9));
		}
		
		private function onLogin(buffer:Buffer):void
		{
			trace("onLogin");
			ModuleHall.it.show();
			IM.Call(Protocol.LOGIN_USER_DATA,onUserData);
			
		}
		
		private function onUserData(buffer:Buffer):void
		{
			trace("onUserData");
		}
		
		private function onClose(event:Event):void {
			if (reconnent > 10) {
				reconnent = 0;
				close();
			} else {
				reconnent++;
				connect();
			}
		}
		
		private function close():void {
			if (im) {
				im.removeEventListener(Event.CONNECT, onConnect);
				im.removeEventListener(IOErrorEvent.IO_ERROR, onClose);
				im.removeEventListener(Event.CLOSE, onClose);
				if (im.connected) {
					im.close();
				}
			}
		}
		
	}
}