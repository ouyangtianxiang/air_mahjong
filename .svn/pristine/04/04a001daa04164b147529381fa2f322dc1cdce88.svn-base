package ge.gpu.program{
	
	public class AGALCircle extends AGAL{
		
		public function AGALCircle(type:String){
			super(type);
		}
		
		protected override function get fragment():String{
			return "tex ft0, v0, fs0 <2d,linear, "+type+">;\n" +
				"sub ft1.xyz,v0.xyz,fc0.xyz\n"+
				"mul ft1.xy,ft1.xy,ft1.xy\n"+
				"add ft1.z,ft1.x,ft1.y\n"+
				"sqt ft1.z,ft1.z\n"+
				"sge ft2.x,fc0.z,ft1.z\n"+
				"mov ft3,ft0\n"+
				"mul ft3.xyzw,ft3.xyzw,ft2.x\n"+
				"mov oc,ft3";
		}
	}
}