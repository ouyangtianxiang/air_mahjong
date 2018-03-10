package ge.gpu.program{
	import flash.display3D.Program3D;
	
	
	public class Program {

		private static var _RBGA:Program;
		public static function get RBGA():Program{
			if(_RBGA==null){
				_RBGA=new Program("nomip");
			}
			return _RBGA;
		}
		
		private static var _DXT1:Program;
		public static function get DXT1():Program{
			if(_DXT1==null){
				_DXT1=new Program("dxt1");
			}
			return _DXT1;
		}
		
		private static var _DXT5:Program;
		public static function get DXT5():Program{
			if(_DXT5==null){
				_DXT5=new Program("dxt5");
			}
			return _DXT5;
		}

		public static const DEFAULT:int=0;
		public static const COLOR:int=1;
		public static const COLORADD:int=2;
		public static const GRAY:int=3;
		public static const FONT:int=4;
		public static const CIRCLE:int=5;
		public static const COOLING:int=6;
		public static const BlendModeADD:int=7;
		
		private var array:Array=[];
		
		public function Program(type:String){
			array[DEFAULT]=new AGAL(type);
			array[COLOR]=new AGALColor(type);
			array[COLORADD]=new AGALColorAdd(type);
			array[GRAY]=new AGALGray(type);
			array[FONT]=new AGALFont(type);
			array[CIRCLE]=new AGALCircle(type);
			array[COOLING]=new AGALCooling(type);
			array[BlendModeADD]=new AGALBlendModeADD(type);
		}

		public function program(i:int=DEFAULT):Program3D{
			return array[i].program3D;
		}
	}
}