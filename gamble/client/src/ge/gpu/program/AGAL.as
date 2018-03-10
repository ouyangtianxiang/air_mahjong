package ge.gpu.program{
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	public class AGAL{
		private static var all:Array=[];
		private static var context3D:Context3D;
		public static function Init(_context3D:Context3D):void{
			context3D=_context3D;
			for each (var agal:AGAL in all){
				agal.init();
			}
		}
		
		protected var type:String;
		
		private var vertexShaderAssembler:AGALMiniAssembler=new AGALMiniAssembler();
		private var fragmentShaderAssembler:AGALMiniAssembler=new AGALMiniAssembler();
		public var program3D:Program3D;
		
		public function AGAL(type:String=null){
			all.push(this);
			this.type=type;
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX,vertex);
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT,fragment);
			init();
		}
		
		protected function get vertex():String{
			return "m44 op, va0, vc0\n" +
				"mov v0, va1";
		}
		
		protected function get fragment():String{
			return "tex ft1, v0, fs0 <2d,linear, "+type+">;\n" +
				"mov oc, ft1";
		}
		
		public function init():void{
			if(context3D){
				dispose();
				program3D=context3D.createProgram();
				program3D.upload(vertexShaderAssembler.agalcode,fragmentShaderAssembler.agalcode);
			}
		}
		
		public function dispose():void{
			if(program3D){
				program3D.dispose();
			}
		}
	}
}