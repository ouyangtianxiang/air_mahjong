package ge.gpu.program{
	public class AGALBlendModeADD extends AGAL{
		public function AGALBlendModeADD(type:String){
			super(type);
		}
		
		protected override function get fragment():String{
			return "tex ft0, v0, fs0 <2d,linear, "+type+">;\n" +
				"max ft0.w, ft0.x, ft0.y\n" +
				"max ft0.w, ft0.z, ft0.w\n" +
				"div ft0.xyz, ft0.xyz, ft0.w\n" +
				"mov oc, ft0";
		}
	}
}