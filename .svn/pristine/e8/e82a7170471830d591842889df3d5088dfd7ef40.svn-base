package ge.gpu.program{
	
	public class AGALCooling extends AGAL{
		
		public function AGALCooling(type:String){
			super(type);
		}
		
		protected override function get vertex():String{
			return "mov vt0,va0\n"+
				"add vt0.z,vt0.z,vc1.x\n"+
				"m44 op,vt0,vc0\n"+
				"mov v0,va1";
		}
		
		protected override function get fragment():String{
			return "tex ft0, v0, fs0 <2d,linear,"+type+">\n" +
				"sub ft1.xyz,v0.xyz,fc0.xyz\n"+
				
				"crs ft3.xyz,ft1.xyz,fc1.xyz\n"+//计算百分比
				"sge ft4.x,ft3.z,fc0.w\n"+//0-1 当前线   ft4.x =1 时表示 在左边 ;=0 时在右边
				
				"crs ft5.xyz,ft1.xyz,fc2.xyz\n"+//计算百分比
				"slt ft4.y,ft5.z,fc0.w\n"+//0-1 中心线  ft4.y =1 时表示 在左边 ;=0 时在右边
				
				"mov ft4.w,fc0.w\n"+
				"slt ft4.w,fc1.x,ft4.w\n"+ //ft4.w 为当前面分比的x轴是否小于 0.5
				
				//计算核心 
				"add ft4.z,ft4.x,ft4.y\n"+
				"add ft4.w,ft4.w,fc2.y\n"+
				"slt ft4.z,ft4.z,ft4.w\n"+
				//
				"mov ft6,ft0\n"+
				"mul ft6,ft6,ft4.z\n"+
				
				"mov oc,ft6";
		}
	}
}