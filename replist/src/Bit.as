package
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLRequest;

	public class Bit extends Loader
	{
		public function Bit(file:File,callback:Function)
		{
			this.contentLoaderInfo.addEventListener(Event.COMPLETE,function(event:Event):void{
				callback((content as Bitmap).bitmapData,file.name);
			});
			this.load(new URLRequest(file.nativePath));
		}
	}
}