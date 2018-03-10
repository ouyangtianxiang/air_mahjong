package ge.gpu.display {
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Vector3D;
	
	import ge.gpu.index.IndexQuad;
	import ge.gpu.program.Program;
	import ge.gpu.texture.BaseTexture;
	
	public class Cooling extends Image {
		public function Cooling(c : GameObject, x : int, y : int, img : int = 0) {
			super(c, x, y, img);
		}
		
		private var vec : Vector3D = new Vector3D();
		private var _angle : Number = 0;
		
		public function get angle() : Number {
			return _angle;
		}
		
		public function set angle(value : Number) : void {
			_angle = value;
			var radian : Number = (360 - value) % 360 * (Math.PI / 180); //求弧度
			vec.x = Math.sin(radian);
			vec.y = Math.cos(radian);
		}
		
		public override function set texture(value : BaseTexture) : void {
			super.texture = value;
			if (value) {
				centre = Vector.<Number>([value.vertex.u + texture.vertex.w / 2, value.vertex.v + texture.vertex.h / 2, 0, 0]);
			}
		}
		private var centre : Vector.<Number>;
		
		protected override function onRender(context3D : Context3D) : void {
			if (_intersect && texture) {
				if(texture.render(context3D)){
					context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, centre);
					context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, Vector.<Number>([vec.x, vec.y, vec.z, vec.w]));
					context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, Vector.<Number>([0, 1, 0, 2]));
					context3D.setProgram(texture.program.program(Program.COOLING));
					context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix3D, true);
					context3D.drawTriangles(IndexQuad.it.buffer);
				}
			}
		}
	}
}
