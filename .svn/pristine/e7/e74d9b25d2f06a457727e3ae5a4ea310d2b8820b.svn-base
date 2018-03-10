package ge.net {
	import flash.utils.ByteArray;
	
	
	/**
	 * @author Administrator
	 */
	public class Bean{
		private static const _view:Object={};
		public static function view(c:Class,alias:String):Table{
			var key:String=c+alias;
			return _view[key]?_view[key]:_view[key]=new Table(c,alias);
		}
		
		private static function _data():ByteArray{
			var data:ByteArray=new ByteArray();
			data.length=1024*1024*2;
			data.writeInt(0);
			pos=data.position;
			return data;
		}
		private static var _pos:int;
		protected static function get pos():int{
			return _pos;
		}
		protected static function set pos(value:int):void{
			if(value>_pos){
				_pos=value;
			}
		}
		
		protected static var data:ByteArray=_data();
		
		public var table : Table;
		public var rank : * ;
		
		public function Init(table : Table) : void {
			this.table = table;
		}
		
		public function get key() : * {
			var len : int = table.keys.length;
			if (len == 1) {
				return this[table.names[table.keys[0]]];
			} else {
				var s : String = "";
				for (var i : int = 0;i < len;i++) {
					s += "-" + this[table.names[table.keys[i]]];
				}
				return s.substring(1);
			}
		}
		
		public function clone() : Bean {
			var o : Bean = new (this.table.C)();
			o.table=table;
			for (var i : int = 0;i < table.names.length;i++) {
				if(table.maps[i]){
					var key : String = table.names[i];
					o[key] = this[key];
				}
			}
			return o;
		}
		
		public function _value(o:Bean):Bean{
			for (var i : int = 0;i < table.names.length;i++) {
				if(table.maps[i]){
					var key : String = table.names[i];
					this[key]=o[key];
				}
			}
			return this;
		}
		
		public function toString() : String {
			var str : String = "";
			for (var i : int = 0;i < table.names.length;i++) {
				var key : String = table.names[i];
				str += "," + key + ":" + (table.maps[i]?this[key]:"*");
			}
			return table.name + ":{" + str.substring(1) + "}";
		}
	}
}
