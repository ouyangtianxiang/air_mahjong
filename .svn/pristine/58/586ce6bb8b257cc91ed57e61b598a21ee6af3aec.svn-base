package game
{
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	[SWF(backgroundColor="0x666666", frameRate="30"]
	public class Loading extends GameAir
	{
		private var logo:Logo;
		public function Loading()
		{
			super("http://code.taobao.org/svn/air_mahjong/gamble/client/bin/");
			logo=new Logo(this,readFile("loading.png"));
			
			logo.setText(0,"aaaaa");
			logo.setText(1,"aaaaa");
			logo.setText(2,"aaaaa");
			logo.setText(3,"aaaaa");
		}
		
		
		protected override function update():void {
			super.update();
		}
		
		protected override function startGame():void {
			logo.remove();
			logo=null;
			var load:Loader = new Loader();
			var bytes:ByteArray = readFile("GameMain.swf");
			var context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			context.allowCodeImport = true;
			load.loadBytes(bytes, context);
			this.addChild(load);
		}
		
		protected override function onProgress(event:ProgressEvent):void
		{
			trace(event.bytesLoaded/event.bytesTotal);
		}
		
		
		protected override function onIOError(event:IOErrorEvent):void
		{
			trace(event);
		}
	}
}