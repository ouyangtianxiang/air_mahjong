package ge.gpu.texture{
	import flash.display3D.Context3D;
	
	import ge.gpu.program.Program;
	import ge.gpu.vertex.Vertex;
	
	public class BaseTexture{
		public var url:String;
		public var subtexture:Object
		public var group:Object
		protected var _root:BaseTexture;
		protected var _vertex:Vertex;
		protected var _program:Program;
		protected var _x:int;
		protected var _y:int;
		protected var _u:int;
		protected var _v:int;
		protected var _rotated:Boolean;
		protected var _width:int;
		protected var _height:int;	
		protected var _fwidth:int;
		protected var _fheight:int;		
		protected var _format:String;
		protected var _scale:Number=1;
		public function BaseTexture(root:BaseTexture=null){
			_root=root?root:this;
		}

		public function dispose():void{
			if(subtexture){
				for each (var sub:BaseTexture in subtexture) {
					sub.dispose();
				}
				subtexture=null;
			}
			group=null;
		}
		
		public function render(context3D:Context3D):Boolean{
			if(_root.rootRender(context3D)){
				_vertex.render(context3D);
				return true;
			}
			return false;
		}
		
		public function rootRender(context3D:Context3D):Boolean{
			return false;
		}
		
		public function get root():BaseTexture { return _root; }
		public function get x():int { return _x; }
		public function get y():int { return _y; }
		public function get u():int { return _u; }
		public function get v():int { return _v; }
		public function get rotated():Boolean { return _rotated; }
		public function get width():int { return _width; }
		public function get height():int { return _height; }
		public function get fwidth():int { return _fwidth; }
		public function get fheight():int { return _fheight; }
		public function get vertex():Vertex { return _vertex; }
		public function get program():Program { return _root._program; }
		public function get scale():Number { return _scale; }
	}
}