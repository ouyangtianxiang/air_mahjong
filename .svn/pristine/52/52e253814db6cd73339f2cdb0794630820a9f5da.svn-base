package ge.gpu.vertex{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.VertexBuffer3D;
	
	public class Vertex{
		private var buffer:VertexBuffer3D;
		public var u:Number;
		public var v:Number;
		public var w:Number;
		public var h:Number;
		public var r:Boolean;
		public var ratio:Number;
		
		public function Vertex(u:Number,v:Number,w:Number,h:Number,ratio:Number,r:Boolean=false){
			this.u=u;
			this.v=v;
			this.w=w;
			this.h=h;
			this.r=r;
			this.ratio=ratio;
		}
		
		private function init():void{
			dispose();
			var us:Vector.<Number>=new <Number>[u,u,u+w,u+w];
			var vs:Vector.<Number>=new <Number>[v,v+h,v+h,v];
			var i:Vector.<int>=r?new <int>[3,0,1,2]:new <int>[0,1,2,3];
			var data:Vector.<Number> = Vector.<Number> 
				([
					//X,Y,  U,	  V		
					0,0,	us[i[0]],vs[i[0]],
					0,-ratio,	us[i[1]],vs[i[1]],
					1,-ratio,	us[i[2]],vs[i[2]],
					1,0,	us[i[3]],vs[i[3]]
				]);
			buffer = context3D.createVertexBuffer(data.length/4, 4); 
			buffer.uploadFromVector(data, 0, data.length/4);
		}
		
		private var context3D:Context3D;
		public function render(context3D:Context3D):void{
			if(this.context3D!=context3D){
				this.context3D=context3D;
				init();
			}
			context3D.setVertexBufferAt(0, buffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			context3D.setVertexBufferAt(1, buffer, 2, Context3DVertexBufferFormat.FLOAT_2);
		}
		
		public function dispose():void{
			if(buffer){
				buffer.dispose();
				buffer=null;
			}
		}
		
		private static var all:Object=new Object();
		public static function full(ratio:Number,u:Number=0,v:Number=0,w:Number=1,h:Number=1):Vertex{
			var key:String=u+""+v+""+w+""+h+""+ratio;
			var vertex:Vertex=all[key];
			if(vertex==null){
				vertex=all[key]=new Vertex(u,v,w,h,ratio);
			}
			return vertex;
		}
	}
}