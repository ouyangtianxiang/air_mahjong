package ge.gpu.program{
	public class AGALColorAdd extends AGALColor{
		public function AGALColorAdd(type:String){
			super(type);
		}
		
		protected override function get fragment():String{
			return "tex ft0, v1, fs0 <2d,linear, "+type+">\n" +
				"mul ft1, fc0, ft0.w\n" +
				"add ft1, ft0, ft1\n" +
				"mul ft1, ft1, fc0.w\n" +
				"mov oc, ft1\n";
		}
	}
}