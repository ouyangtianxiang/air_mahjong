package ge.gpu.texture{
	import flash.utils.ByteArray;
	
	import game.res.LoadBinary;
	
	import ge.global.Atf;
	
	public class UITexture{
		private static var uis:Object={};
		public static function Load(path:String,name:String,onLoad:Function):void{
			uis[name]=new UITexture(path,name,onLoad);
		}
		
		public static function UI(name_index:String,rows:int=1,cols:int=1):*{
			var arr:Array=name_index.split(".");
			var name:String=arr[0]
			var index:int=arr[1]
			var ui:UITexture=uis[name];
			if(ui){
				var texture:*=ui.getTexture(index,rows,cols);
				if(texture){
					return texture;
				}else{
					throw(new Error("UITexture:UI(->"+index+")"));
				}
			}
			return null;
		}
		
		private var url:String;
		private var xml:XML;
		private var atf:ATFTexture=new ATFTexture();
		private var onLoad:Function;
		public function UITexture(path:String,name:String,onLoad:Function):void{
			this.url=path+name;
			this.onLoad=onLoad;
			new LoadBinary(url+".xml",onXML)
		}
		
		private function onXML(data:ByteArray) : void {
			xml=new XML(data);
			atf.load(url+Atf,parse);
		}
		
		protected function parse(atf:ATFTexture):void{
			var childs:XMLList=xml.children();
			var len:int=childs.length();
			atf.subtexture={};
			for(var i:int=0;i<len;i++){
				var c:XML=childs[i];
				atf.subtexture[c.@name]=new SubTexture(atf,c);
			}
			onLoad();
		}
		
		public function getTexture(index:int,rows:int=1,cols:int=1):*{
			if(rows*cols==1){
				return atf.subtexture[index];
			}
			var texture:SubTexture=atf.subtexture[index];
			if(texture.subtexture==null){
				texture.subtexture=[];
				var w:int=texture.width/rows;
				var h:int=texture.height/cols;
				for(var j:int=0;j<cols;j++){
					for(var i:int=0;i<rows;i++){
						var st:SliceTexture=new SliceTexture(texture,i*w,j*h,w,h,texture.rotated);
						texture.subtexture.push(st);
					}
				}
			}
			return texture.subtexture;
		}
	}
}


