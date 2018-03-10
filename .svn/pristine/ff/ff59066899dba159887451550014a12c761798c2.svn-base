package ge.net {
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.utils.Endian;
	
	import ge.utils.tick.Tick;
	
	public class IM extends Socket {
		private static var it : IM;
		
		public function IM(ip : String, port : int) : void {
			it = this;
			super(ip, port);
			endian = Endian.LITTLE_ENDIAN;
			addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
			addEventListener(Event.CONNECT, onConnect);
			addEventListener(IOErrorEvent.IO_ERROR, onIoError);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			addEventListener(Event.CLOSE, onClose);
		}
		
		// 错误处理
		private function onIoError(event : IOErrorEvent) : void {
			trace("ioErrorHandler信息： " + event + "\n");
		}
		
		// 安全问题处理
		private function onSecurityError(event : SecurityErrorEvent) : void {
			trace("securityErrorHandler信息: " + event + "\n");
		}
		
		// 关闭Socket连接
		private function onClose(event : Event) : void {
			trace("连接关闭" + "\n");
		}
		
		// 连接成功回调
		private function onConnect(event : Event) : void {
		}
		
		// 包长
		private var len : uint = 0;
		
		
		/**
		 * 接收服务器数据
		 */
		private function onSocketData(event : ProgressEvent) : void {
			while (connected) {
				// 新包
				if (len == 0) {
					if (this.bytesAvailable < 1) {
						break;
					}
					// 包长
					len = this.readUnsignedByte();
				}
				if(len==251){
					if (this.bytesAvailable < 2) {
						break;
					}
					len=this.readUnsignedShort();
				}else if(len==252){
					if (this.bytesAvailable < 4) {
						break;
					}
					len=this.readUnsignedInt();	
				}
				if (this.bytesAvailable < len) {
					// 非整包
					break;
				}
				var buffer:Buffer=new Buffer();
				this.readBytes(buffer, 0, len);
				len = 0;
				try {
					handler(buffer);
				} catch(error : Error) {
					trace(error.getStackTrace());
				}
			}
		}
		
		/**
		 *发送数据 
		 */
		private function sendMsg(index : uint, param : Array) : void {
			var buffer:Buffer=new Buffer();
			buffer.writeCode(index);
			buffer.writeArray(param);
			if(connected){
				send(buffer);
			}else{
				dispatchEvent(new Event(Event.CLOSE));
			}
		}
		
		private function send(buffer:Buffer):void{
				writeShort(buffer.length);
				writeBytes(buffer);
				flush();
		}
		
		private static var callbacks : Object = new Object();
		
		public static function Call(method : int, callback : Function, ...param : *) : void {
			if (callback != null) {
				callbacks[method]=callback;
			}
			it.sendMsg(method, param);
		}
		
		private static var listeners : Object = new Object();
		
		public static function addMsgListener(code : int, listener : Function,priority:Boolean=false) : void {
			var list : Array = listeners[code];
			if (list == null) {
				list = [];
				listeners[code] = list;
			}
			if (list.indexOf(listener) < 0 ) {
				if(priority){
					list.unshift(listener);
				}else{
					list.push(listener);
				}
			}
		}
		
		public static function removeMsgListener(code : int, listener : Function) : void {
			var list : Array = listeners[code];
			if (list != null) {
				var i : int = list.indexOf(listener);
				if (i >= 0 ) {
					list.splice(i, 1);
				}
			}
		}
		public static function Handler(buffer : Buffer) : void {
			it.handler(buffer);
		}
		public function handler(buffer : Buffer) : void {
			var code : int = buffer.readCode();
			switch(code) {
				case 0:
					Table.Init(buffer);
					break;
				case 1:
					Table.Insert(buffer);
					break;
				case 2:
					Table.Delete(buffer);
					break;
				case 3:
					Table.Update(buffer);
					break;
				case 4:
					break;
				case 5:
					Tick.it.Time = buffer.readDouble();
					Call(5, null);
					break;
				case 9:
					throw(new Error("ServerError:\n" + buffer.readUTF(),9));
					break;
				default:
					onCall(code, buffer);
			}
		}
		
		private static function onCall(code : int, buffer : Buffer) : void {
			var p:int=buffer.position;
			var callback:Function=callbacks[code];
			if(callback!=null){
				delete callbacks[code];
				callback(buffer);
			}
			var list : Array = listeners[code];
			if(list){
				for(var i:int=0;i<list.length;i++){
					var fun:Function=list[i];
					buffer.position=p;
					fun(buffer);
					if(buffer.length==0){
						return;
					}
				}
			}
		}
	}
}