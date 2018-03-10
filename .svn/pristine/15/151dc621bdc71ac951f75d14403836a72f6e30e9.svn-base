package ge.gpu.texture{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.Texture;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import game.res.LoadBinary;
	
	import ge.gpu.program.Program;
	import ge.gpu.vertex.Vertex;
	
	public class ATFTexture extends BaseTexture	{
		private static var _context3D:Context3D;
		public static function Init(context3D:Context3D):void{
			_context3D=context3D;
		}
		
		private var context3D:Context3D;
		protected var available:Boolean;
		protected var texture:Texture;
		protected var callback:Function;
		public var type:int;
		public function ATFTexture(){
		}
		
		public function load(url:String,onLoad:Function):void{
			available=false;
			this.url=url;
			this.callback=onLoad;
			new LoadBinary(url,onComplete);
		}
		
		public function set scale(value:Number):void{
			_scale=value;
		}
		
		protected var bytes:ByteArray;
		protected function onComplete(byteArray:ByteArray):void	{
			data(byteArray);
			init();
		}
		
		private function init():void{
			context3D=_context3D;
			try{
				texture = context3D.createTexture(_width, _height,_format,true);
				texture.addEventListener(Event.TEXTURE_READY,onTextureReady)
				texture.uploadCompressedTextureFromByteArray(bytes,0,true);
				bytes.clear();
				bytes=null;
			} catch(error : Error) {
			}
		}
		
		protected function onTextureReady(event:Event):void{
			available=true;
			if(callback!=null){
				callback(this);
				callback=null;
			}
		}
		
		public override function rootRender(_3d:Context3D):Boolean{
			if(available){
				if(context3D==_context3D){
					context3D.setTextureAt(0, texture);
					return true;
				}else{
					load(url,null);
					return false;
				}
			}else if(bytes){
				init();
			}
			return false;
		}
		
		public override function dispose():void{
			super.dispose();
			available=false;
			if(texture){
				texture.dispose();
				texture=null;
			}
		}
		
		private function data(value:ByteArray):void{
			bytes=value;
			var atf:String = String.fromCharCode(bytes[0], bytes[1], bytes[2]);
			if (atf != "ATF"){
				bytes.uncompress();	
			}
			type=bytes[6];
			switch (type){
				case 0:
				case 1:
					_format = Context3DTextureFormat.BGRA;
					_program=Program.RBGA;
					break;
				case 2:
				case 3:
					_format = Context3DTextureFormat.COMPRESSED;
					_program=Program.DXT1;
					break;
				case 4:
				case 5: 
					_format = Context3DTextureFormat.COMPRESSED_ALPHA; 
					_program=Program.DXT5;
					break;
				default: throw new Error("Invalid ATF format");
			}
			_width = Math.pow(2, bytes[7]); 
			_height = Math.pow(2, bytes[8]);
			//mNumTextures = data[9];
			_vertex=Vertex.full(_height/_width);
		}
	}
}