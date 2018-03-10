package ge.gpu.texture{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.TextureBase;
	
	import ge.gpu.program.Program;
	import ge.gpu.vertex.Vertex;
	
	public class BitmapTexture extends BaseTexture{
		protected var texture:TextureBase;
		protected var _bitmapData:BitmapData;
		private var context3D:Context3D;
		public function init():void{
			if(context3D && _bitmapData){
				if(texture){
					texture.dispose();
				}
				var _rectangleTexture:RectangleTexture = context3D.createRectangleTexture(_width, _height,_format,false);
				_rectangleTexture.uploadFromBitmapData(_bitmapData);
				texture=_rectangleTexture;
			}
		}
		
		public override function rootRender(context3D:Context3D):Boolean{
			if(this.context3D!=context3D){
				this.context3D=context3D;
				init()
			}
			context3D.setTextureAt(0, texture);
			return true;
		}
		
		public override function dispose():void{
			_vertex=null;
			super.dispose();
			if(_bitmapData){
				_bitmapData.dispose();
				_bitmapData=null;
			}
		}
		
		public function set data(value:BitmapData):void{
			_bitmapData = value;
			_format = value.transparent?Context3DTextureFormat.BGRA:Context3DTextureFormat.BGR_PACKED;
			_program=Program.RBGA;
			_width=_bitmapData.width;
			_height=_bitmapData.height;
			_vertex=Vertex.full(_height/_width);
		}
	}
}