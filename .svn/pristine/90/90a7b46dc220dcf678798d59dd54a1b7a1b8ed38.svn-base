package game
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	
	public class Logo extends Sprite
	{
		private var logo:Loader;
		private var text:Vector.<Text>=new Vector.<Text>(4);
		private var txt2:Text;
		public function Logo(c:Sprite,bytes:ByteArray)
		{
			c.addChild(this);
			logo=new Loader();
			this.addChild(logo);
			logo.contentLoaderInfo.addEventListener(Event.COMPLETE,onCompleteLogo);
			logo.loadBytes(bytes);
			
			text[0]=new Text(this,0,0,0xFF0000,30,new Point(0,0));
			text[1]=new Text(this,stage.fullScreenWidth,0,0xFF0000,30,new Point(1,0));
			text[2]=new Text(this,0,stage.fullScreenHeight,0xFF0000,30,new Point(0,1));
			text[3]=new Text(this,stage.fullScreenWidth,stage.fullScreenHeight,0xFF0000,30,new Point(1,1));
		}
		
		protected function onCompleteLogo(event:Event):void
		{
			logo.x=(stage.fullScreenWidth-logo.width)/2;
			logo.y=(stage.fullScreenHeight-logo.height)/2;
		}
		
		public function remove():void{
			logo.unload();
			logo=null;
			parent.removeChild(this);
		}
		
		public function setText(index:int,value:String):void{
			text[index].text=value;
		}
	}
}