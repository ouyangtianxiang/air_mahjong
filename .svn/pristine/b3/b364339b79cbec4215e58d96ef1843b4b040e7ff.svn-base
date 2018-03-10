package ge.gpu.utils{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	
	import ge.gpu.program.Program;
	
	public class ColorTransform{
		private var index:int;
		private var isOverlap:Boolean;
		private var vector:Vector.<Number>=new Vector.<Number>(4);
		
		public function color(color:uint,alpha:Number,_overlap:Boolean):void{
			index=_overlap?Program.COLORADD:Program.COLOR;
			vector[0]=(color>>16&0xFF)/0xFF;
			vector[1]=(color>>8&0xFF)/0xFF;
			vector[2]=(color&0xFF)/0xFF;
			vector[3]=alpha;
		}
		
		public function gray(alpha:Number):void{
			index=Program.GRAY;
			vector[0]=0.299;
			vector[1]=0.587;
			vector[2]=0.114;
			vector[3]=alpha;
		}
		
		public function blendModeAdd():void{
			index=Program.BlendModeADD;
			vector[0]=0.299;
			vector[1]=0.587;
			vector[2]=0.114;
			vector[3]=1;
		}
		
		public function circle(x:Number,y:Number,r:Number):void{
			index=Program.CIRCLE;
			vector[0]=x;
			vector[1]=y;
			vector[2]=r;
			vector[3]=0;
		}
		
		public function font(color:uint,stroke:Boolean):void{
			index=Program.FONT;
			vector[0]=(color>>16&0xFF)/0xFF;
			vector[1]=(color>>8&0xFF)/0xFF;
			vector[2]=(color&0xFF)/0xFF;
			vector[3]=stroke?1:0;
		}
		
		public function render(context3D : Context3D,program:Program) : void {
			context3D.setProgram (program.program(index));
			context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, vector);
		}
	}
}