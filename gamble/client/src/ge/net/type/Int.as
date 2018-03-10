package ge.net.type{
	import flash.utils.ByteArray;

	public class Int{
		private static function _data():ByteArray{
			var data:ByteArray=new ByteArray();
			data.length=1024*128;
			data.writeInt(0);
			return data;
		}
		
		private static var POS:int=0;
		protected static var data:ByteArray=_data();
		
		private var pos:int=0;
		public function Int(value:Number=0) {
			pos=POS;
			POS+=8;
			this.value=value;
		}
		
		public function get value() : Number {
			data.position=pos;
			return data.readDouble();
		}
		
		public function set value(value:Number) : void {
			data.position=pos;
			data.writeDouble(value);
		}
	}
}