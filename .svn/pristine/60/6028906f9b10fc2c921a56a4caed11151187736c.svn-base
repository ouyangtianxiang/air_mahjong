package ge.gpu.texture{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import ge.global.Atf;
	
	public class LoadTexture extends EventDispatcher{
		public static const RES : Object = new Object();
		public static function Load(url:String,callback:Function):void{
			var load:LoadTexture=RES[url];
			if(load==null){
				load=new LoadTexture(url);
				RES[url]=load;
			}
			load.init(callback);
		}
		
		public static function Dispose(url:String):void{
			var load:LoadTexture=RES[url];
			if(load){
				load.dispose();
			}
		}
		
		private var xml:XML;
		private var atf:ATFTexture;
		
		private var url:String;
		
		public function LoadTexture(url:String){
			this.url=url;
			new ATFTexture().load(url,onComplete);
		}
		
		private function init(callback:Function):void{
			if (atf) {
				callback(atf);
			} else {
				addEventListener(Event.COMPLETE, function(event:Event):void{
					callback(atf);
				});
			}
		}
		
		private function onXML(data:ByteArray) : void {
			xml=new XML(data);
			var atf:ATFTexture=new ATFTexture();
			atf.load(url+Atf,parse);
		}		
		
		protected function onComplete(atf:ATFTexture):void{
			this.atf=atf;
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function parse(atf:ATFTexture):void{
			this.atf=atf;
			var childs:XMLList=xml.children();
			var len:int=childs.length();
			atf.subtexture={};
			for(var i:int=0;i<len;i++){
				var c:XML=childs[i];
				atf.subtexture[c.@name]=new SubTexture(atf,c);
			}
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function dispose():void{
			atf.dispose();
			atf=null;
			delete RES[url];
		}
	}
}


