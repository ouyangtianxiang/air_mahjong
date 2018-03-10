package game {
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoaderDataFormat;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import game.font.FONT;
	import game.font.GameFont;
	
	public class GameAir extends Sprite {
		private var storageDir:File = File.applicationStorageDirectory;
		private var appDir:File = File.applicationDirectory;
		private var version:ByteArray;
		private var filename:String;
		private var versionInfo:ByteArray;
		private var newVersionInfo:Object
		private var url:String;
		
		public function GameAir(url:String) {
			this.url=url;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.showDefaultContextMenu = false;
			stage.stageFocusRect = false;
			FONT = GameFont.font;
			start();
		}
		
		private function start(event:* = null):void
		{
			new Load(url+"url",onUrl,start);
		}
		
		protected function onUrl(event:Event):void
		{
			url=String(event.target.data);
			new Load(url+"version",onVersion,onIOError);
		}
		
		private function onVersion(event:Event):void
		{
			version=event.target.data;
			var newVersion:String=String(event.target.data);
			var localversion:String=String(readFile("version"));
			if(newVersion==localversion){
				startGame();
			}else{
				new Load(url+"versionInfo",onVersionInfo,onIOError);
			}
		}
		
		private function onVersionInfo(event:Event):void
		{
			versionInfo=event.target.data;
			newVersionInfo =toMap(String(versionInfo));
			var localVersionInfo:Object =toMap(String(readFile("versionInfo")));
			for each (var array:Array in localVersionInfo) 
			{
				var arr:Array=newVersionInfo[array[0]];
				if(arr){
					if(arr[1]==array[1]&&arr[2]==array[2]){
						delete newVersionInfo[array[0]];
					}
				}
			}
			update();
		}
		
		protected function update():void {
			for (var key:String in newVersionInfo) 
			{
				filename=key;
				var load:Load = new Load(url+filename, onComplete,onIOError);
				load.dataFormat = URLLoaderDataFormat.BINARY;
				load.addEventListener(ProgressEvent.PROGRESS, onProgress);
				return;
			}
			saveFile(version, "version");
			saveFile(versionInfo, "versionInfo");
			startGame();
		}
		
		protected function startGame():void {
			var load:Loader = new Loader();
			var bytes:ByteArray = readFile("GameMain.swf");
			var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			context.allowCodeImport = true;
			load.loadBytes(bytes, context);
			this.addChild(load);
		}
		
		private function onComplete(event:Event):void {
			saveFile(event.target.data, filename);
			delete newVersionInfo[filename];
			update();
		}
		
		protected function onProgress(event:ProgressEvent):void
		{
		}
		
		
		protected function onIOError(event:IOErrorEvent):void
		{
		}
		
		private function toMap (str:String):Object	{
			var obj:Object={};
			var array:Array=str.split(/\r\n|\r|\n/);
			for each (var s:String in array) 
			{
				var arr:Array=s.split(",");
				if(arr.length==3){
					obj[arr[0]]=arr;
				}
			}
			return obj;
		}
		
		public function readFile(path:String):ByteArray {
			var file:File = storageDir.resolvePath(path);
			if (!file.exists) {
				file=appDir.resolvePath(path);
				if (!file.exists) {
					return null;
				}
			}
			var fs:FileStream = new FileStream();
			fs.open(file, FileMode.READ);
			var bytes:ByteArray = new ByteArray();
			fs.readBytes(bytes);
			fs.close();
			return bytes;
		}
		
		private function saveFile(data:ByteArray, path:String):void {
			var save:File = storageDir.resolvePath(path);
			var fs:FileStream = new FileStream();
			fs.open(save, FileMode.WRITE);
			fs.writeBytes(data);
			fs.close();
		}
	}
}