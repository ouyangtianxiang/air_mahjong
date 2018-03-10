package ge.gpu.texture{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	
	import game.res.LoadBinary;
	
	import ge.global.Atf;
	
	public class MCTexture extends EventDispatcher{
		public static const RES : Object = new Object();
		public static function Load(url:String,callback:Function):void{
			var load:MCTexture=RES[url];
			if(load==null){
				load=new MCTexture(url);
				RES[url]=load;
			}
			load.init(callback);
		}
		
		public static function Dispose(url:String):void{
			var load:MCTexture=RES[url];
			if(load){
				load.dispose();
			}
		}
		
		private var url:String;
		private var atf:ATFTexture=new ATFTexture();
		public function MCTexture(url:String){
			this.url=url;
			atf.load(url+Atf,onAtf);
		}
		
		public function init(callback:Function):void{
			if (atf.subtexture) {
				callback(atf);
			} else {
				addEventListener(Event.COMPLETE, function(event:Event):void{
					callback(atf);
				});
			}
		}
		
		private function onAtf(atf:ATFTexture):void{
			new LoadBinary(url+".xml",onXML);
		}
		
		private function onXML(data:ByteArray) : void {
			var xml:XML=new XML(data);
			if(xml.@scale!=undefined){
				atf.scale=1/xml.@scale
			}
			var childs:XMLList=xml.children();
			var len:int=childs.length();
			atf.subtexture=new Vector.<BaseTexture>(len);
			atf.group={};
			for(var i:int=0;i<len;i++){
				var c:XML=childs[i];
				atf.subtexture[i]=new SubTexture(atf,c);
				var name:String=c.@name;
				var p:int=name.lastIndexOf("/");
				var g:*=p>0?name.substr(0,p):0;
				var vector:Vector.<int>=atf.group[g];
				if(vector==null){
					vector=new Vector.<int>();
					atf.group[g]=vector;
				}
				vector.push(i);
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



