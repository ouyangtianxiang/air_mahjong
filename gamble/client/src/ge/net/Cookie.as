package ge.net {
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	
	/**
	 * @author Administrator
	 */
	public class Cookie {
		private static var _it : Cookie;
		
		public static function get it() : Cookie {
			if (_it == null) {
				_it = new Cookie();
			}
			return _it;
		}
		
		public var obj : Object;
		private var funName:String="CallBacks";
		private var callBack:Function;
		
		public function open(callBack:Function):void {
			this.callBack=callBack;
			if (ExternalInterface.available) {
				ExternalInterface.addCallback(funName,CallBacks);
				var str : String = "javascript:document." + ExternalInterface.objectID + "."+funName+"(document.cookie)";				navigateToURL(new URLRequest(str), "_self");
			}
		}
		
		private function CallBacks(cookie : String) : void {
			trace(cookie);
			var array : Array = cookie.split("; ");
			obj = new Object();
			for each (var arr : String in array) {
				var kv : Array = arr.split("=");
				obj[kv[0]] = kv[1];
			}
			callBack();
			callBack=null;
		}
		
		public function Get(name:String):String{
			return obj[name];
		}
	}
}
