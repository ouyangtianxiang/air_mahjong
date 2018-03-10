package ge.gpu.program{
	public class AGALFont extends AGALColor{
		public function AGALFont(type:String){
			super(type);
		}
		
		protected override function get fragment():String{
			return "tex ft0, v1, fs0 <2d,linear, "+type+">\n" +	
				"mul ft1, fc0.xyz, ft0.x\n" +
				"mul ft1.w, fc0.w, ft0.y\n" +
				"max ft1.w, ft1.w, ft0.x\n" +
				"mov oc, ft1\n";
		}
	}
}