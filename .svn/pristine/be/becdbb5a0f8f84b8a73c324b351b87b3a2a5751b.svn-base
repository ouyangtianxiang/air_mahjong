package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLRequest;
	
	public class PLua extends Sprite
	{
		public var file:File;
		public var bd:BitmapData;
		public var dir:File;
		private var loader:Loader=new Loader();
		public function PLua()
		{
			this.file=new File(MahjongImage["path"]);
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onComplete);
			

			loader.load(new URLRequest(file.nativePath));
		}
		
		protected function onComplete(event:Event):void
		{
			dir=new File(file.nativePath.replace(".png",""));
			dir.createDirectory();
			
			bd=Bitmap(loader.content).bitmapData;
			var obj:Object=MahjongImage["MahjongImage_map"];
			for(var k:String in obj){				
				new FrameLua(k,obj[k],this);
			}
		}
	}
}