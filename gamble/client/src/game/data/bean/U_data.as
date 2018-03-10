package game.data.bean {
	import ge.net.Bean;
	import ge.net.Table;

	/**
	 *  (3)
	 */
	public class U_data extends Bean {
		public static const names : Array = ["userId", "state", "roomCard"];
		public static const types : Array = [3, 1, 3];
		public static const maps : Array = [true, true, true];
		public static const keys : Array = [0];
		public static const table : Table = new Table(U_data);
		public static function view (alias:String): Table {
			return Bean.view(U_data,alias);
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
		public function get roomCard():int{
			data.position=_roomCard;
			return data.readInt();
		}

		/**
		 * 
		 */
		public function set roomCard(value:int):void{
			data.position=_roomCard=_roomCard==0?pos:_roomCard;
			data.writeInt(value);
			pos=data.position;
		}
		private var _roomCard:int;
	}
}