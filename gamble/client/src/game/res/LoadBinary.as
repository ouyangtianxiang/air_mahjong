package game.res {
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import game.Config;
	
	public class LoadBinary {
		
		private var callback : Function;
		private var save : File;
		private var url:String;
		
		public function LoadBinary(url : String, callback : Function) {
			this.url=url;
			this.callback = callback;
			//增量包
			var storageDir : File = File.applicationStorageDirectory;
			var file : File = storageDir.resolvePath(url);
			//初包
			if (!file.exists) {
				save = file;
				var appDir : File = File.applicationDirectory;
				file = appDir.resolvePath(url);
				if (!file.exists) {
					//网络
					var loader : URLLoader = new URLLoader();
					loader.dataFormat = URLLoaderDataFormat.BINARY;
					loader.addEventListener(Event.COMPLETE, onComplete);
					loader.load(new URLRequest(Config.xml["res"] + url));
					return;
				}
			}
			
			var fs : FileStream = new FileStream();
			fs.addEventListener(Event.COMPLETE, onComplete2);
			fs.openAsync(file,FileMode.READ);
		}
		
		protected function onComplete2(event:Event):void{
			var fs : FileStream = event.target as FileStream;
			var data : ByteArray = new ByteArray();
			fs.readBytes(data);
			callback(data);
			fs.close();
		}
		
		protected function onComplete(event : Event) : void {
			var data : ByteArray = event.target.data;
			if (save) {
				var fs : FileStream = new FileStream();
				fs.open(save, FileMode.WRITE);
				fs.writeBytes(data);
				fs.close();
			}
			callback(data);
		}
	}
}
