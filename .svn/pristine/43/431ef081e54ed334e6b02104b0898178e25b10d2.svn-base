package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;

	public class Plist extends Loader
	{
		public var replist:Replist;
		public var file:File;
		public var bd:BitmapData;
		public var dir:File;
		public function Plist(file:File,replist:Replist)
		{
			this.file=file;
			this.replist=replist;
			
			this.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
			this.load(new URLRequest(file.nativePath.replace(".plist",".png")));
		}
		
		protected function onComplete(event:Event):void
		{
			dir=new File(file.nativePath.replace(".plist",""));
			dir.createDirectory();
			
			bd=Bitmap(content).bitmapData;
			var fs:FileStream=new FileStream();
			fs.open(file,FileMode.READ);
			var data:ByteArray=new ByteArray();
			fs.readBytes(data,file.size);
			var str:String=String(data);
			var n:int=str.indexOf("<plist");
			
			var root:XML=XML(str.substr(n));
			var xml:XML=root.children()[0];
			var frames:XML=xml.children()[1];
			var xmllist:XMLList=frames.children();
			for(var i:int=0;i<xmllist.length();i+=2){
				var key:XML=xmllist[i];
				var dict:XML=xmllist[i+1];
				
				new Frame(key.text(),dict,this);
			}
			
			replist.next();
		}
	}
}