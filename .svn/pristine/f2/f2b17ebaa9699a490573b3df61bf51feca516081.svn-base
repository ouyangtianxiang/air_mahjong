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

	public class Fnt extends Loader
	{
		public var replist:ReFont;
		public var file:File;
		public var bd:BitmapData;
		public var dir:File;
		public function Fnt(file:File,replist:ReFont)
		{
			this.file=file;
			this.replist=replist;
			
			this.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
			this.load(new URLRequest(file.nativePath.replace(".fnt",".png")));
		}
		
		protected function onComplete(event:Event):void
		{
			dir=new File(file.nativePath.replace(".fnt",""));
			dir.createDirectory();
			
			bd=Bitmap(content).bitmapData;
			var fs:FileStream=new FileStream();
			fs.open(file,FileMode.READ);
			var data:ByteArray=new ByteArray();
			fs.readBytes(data,file.size);
			
			var str:String=String(data);
			var array:Array=str.split("\n");
			var arr:Array=String(array[0]).split("size=");
			var size:int=String(arr[1]).split(" ")[0];
			trace(size);
			for each (var s:String in array) 
			{
				if(s.indexOf("char id=")==0){
					new FrameFnt(s,this,size);
				}
			}
			
						
			replist.next();
		}
	}
}