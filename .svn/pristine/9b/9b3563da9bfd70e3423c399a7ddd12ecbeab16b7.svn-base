package ge.gpu.program{
	public class AGALColor extends AGAL{
		public function AGALColor(type:String){
			super(type);
		}
		
		protected override function get vertex():String{
			return "m44 op, va0, vc0\n" +
				"mov v0, va0\n" +
				"mov v1, va1\n";
		}
		
		protected override function get fragment():String{
			return "tex ft0, v1, fs0 <2d,linear, "+type+">\n" +	
				"mul ft1, fc0, ft0\n" +
				"mov oc, ft1\n";
		}
	}
}