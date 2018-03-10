package game.data.bean {
	import ge.net.Bean;
	import ge.net.Table;

	/**
	 *  (3)
	 */
	public class T_state extends Bean {
		public static const names : Array = ["userId", "index", "state"];
		public static const types : Array = [3, 1, 1];
		public static const maps : Array = [true, true, true];
		public static const keys : Array = [0];
		public static const table : Table = new Table(T_state);
		public static function view (alias:String): Table {
			return Bean.view(T_state,alias);
		}


		/**
		 * $
		 */
		public function get userId():int{
			data.position=_userId;
			return data.readInt();
		}

		/**
		 * $
		 */
		public function set userId(value:int):void{
			data.position=_userId=_userId==0?pos:_userId;
			data.writeInt(value);
			pos=data.position;
		}
		private var _userId:int;


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
	}
}