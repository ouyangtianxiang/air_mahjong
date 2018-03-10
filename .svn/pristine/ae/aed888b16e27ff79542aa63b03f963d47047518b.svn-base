package ge.gpu.index{
	import flash.display3D.Context3D;
	import flash.display3D.IndexBuffer3D;
	
	public class IndexQuad{
		public static const it:IndexQuad=new IndexQuad();
		private static var context3D:Context3D;
		public static function Init(_context3D:Context3D):void{
			context3D=_context3D;
			it.init();
		}
		private var _buffer:IndexBuffer3D;
		private var data:Vector.<uint> = Vector.<uint> (array);
		public function IndexQuad()	{
			init();
		}
		
		protected function get array():Array{
			return [0, 1, 2, 		0, 2, 3];
		}
		
		public function init():void{
			if(context3D){
				dispose();
				_buffer = context3D.createIndexBuffer(data.length);
				_buffer.uploadFromVector(data, 0, data.length);
			}
		}
		
		public function dispose():void{
			if(_buffer){
				_buffer.dispose();
				_buffer=null;
			}
		}
		
		public function get buffer():IndexBuffer3D	{
			return _buffer;
		}
	}
}