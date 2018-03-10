package game.data.bean {
	import ge.net.Bean;
	import ge.net.Table;

	/**
	 *  (4)
	 */
	public class T_brand extends Bean {
		public static const names : Array = ["id", "value", "state", "index"];
		public static const types : Array = [3, 1, 1, 1];
		public static const maps : Array = [true, true, true, true];
		public static const keys : Array = [0];
		public static const table : Table = new Table(T_brand);
		public static function view (alias:String): Table {
			return Bean.view(T_brand,alias);
		}


		/**
		 * $
		 */
		public function get id():int{
			data.position=_id;
			return data.readInt();
		}

		/**
		 * $
		 */
		public function set id(value:int):void{
			data.position=_id=_id==0?pos:_id;
			data.writeInt(value);
			pos=data.position;
		}
		private var _id:int;


		/**
		 * 
		 */
		public function get value():int{
			data.position=_value;
			return data.readByte();
		}

		/**
		 * 
		 */
		public function set value(value:int):void{
			data.position=_value=_value==0?pos:_value;
			data.writeByte(value);
			pos=data.position;
		}
		private var _value:int;


		/**
		 * 
		 */
		public function get state():int{
			data.position=_state;
			return data.readByte();
		}

		/**
		 * 
		 */
		public function set state(value:int):void{
			data.position=_state=_state==0?pos:_state;
			data.writeByte(value);
			pos=data.position;
		}
		private var _state:int;


		/**
		 * 
		 */
		public function get index():int{
			data.position=_index;
			return data.readByte();
		}

		/**
		 * 
		 */
		public function set index(value:int):void{
			data.position=_index=_index==0?pos:_index;
			data.writeByte(value);
			pos=data.position;
		}
		private var _index:int;
	}
}