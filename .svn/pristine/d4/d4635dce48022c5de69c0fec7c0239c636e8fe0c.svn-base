package game.data {
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import game.res.LoadBinary;
	import game.utils.Protocol;
	
	import ge.net.Buffer;
	import ge.net.IM;
	
	/**
	 * 加载系统表
	 * @author Administrator
	 */
	public class ST {
		private static var it : ST;
		
		public static function Load(callback : Function) : void {
			if (it) {
				callback();
			} else {
				it = new ST(callback);
			}
		}
		
		private var url : String = "res/SystemTable.data"
		private var callback : Function;
		
		public function ST(callback : Function) {
			this.callback = callback;
			var file : File = File.applicationStorageDirectory.resolvePath(url);
			if (!file.exists) {
				file = File.applicationDirectory.resolvePath(url);
			}
			if (!file.exists) {
				request();
			} else {
				new LoadBinary(url, onLoad)
			}
		}
		
		private var buffer : Buffer = new Buffer();
		
		private function onLoad(data : ByteArray) : void {
			md5 = data.readUTFBytes(32);
			data.readBytes(buffer);
			request();
		}
		private var md5 : String = "";
		
		private function request() : void {
			IM.Call(Protocol.LOGIN_SYSTEM_DATA, onSysData, md5);
		}
		
		private function onSysData(data : Buffer) : void {
			var code : int = data.readByte();
			if (code == 1) {
				md5 = data.readUTFBytes(32);
				buffer.clear();
				data.readBytes(buffer);
				save();
			}
			onSystemTable();
		}
		
		private function save() : void {
			var save : File = File.applicationStorageDirectory.resolvePath(url);
			var data : ByteArray = new ByteArray();
			data.writeUTF(md5);
			data.writeBytes(buffer);
			var fs : FileStream = new FileStream();
			fs.open(save, FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
		
		private function onSystemTable() : void {
			buffer.uncompress();
			while (buffer.position < buffer.length) {
				IM.Handler(buffer);
			}
			callback();
			buffer.clear();
			buffer = null;
		}
	}
}
