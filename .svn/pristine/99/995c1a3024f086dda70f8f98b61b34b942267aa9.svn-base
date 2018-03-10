package ge.gpu.program
{
	public class AGALGray extends AGALColor{
		public function AGALGray(type:String){
			super(type);
		}
		
		protected override function get fragment():String{
			return "tex ft0, v1, fs0 <2d,linear, "+type+">\n" +	
				"mul ft0.xyz, fc0.xyz, ft0.xyz\n" +
				"add ft1, ft0.x, ft0.y\n" +
				"add ft1, ft1, ft0.z\n" +
				"mul ft1.w, fc0.w,ft0.w\n"+
				"mov oc, ft1\n";
		}
	}
}