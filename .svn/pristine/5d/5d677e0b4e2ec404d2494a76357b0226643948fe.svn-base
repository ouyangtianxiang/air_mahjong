package game.data.bean {
	import ge.net.Bean;
	import ge.net.Table;

	/**
	 * @用户信息表(登录时更新) (6)
	 */
	public class U_info extends Bean {
		public static const names : Array = ["id", "passId", "password", "regTime", "loginTime", "ip"];
		public static const types : Array = [3, 6, 6, 3, 3, 3];
		public static const maps : Array = [true, true, true, true, true, true];
		public static const keys : Array = [0];
		public static const table : Table = new Table(U_info);
		public static function view (alias:String): Table {
			return Bean.view(U_info,alias);
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
		 * 通行证id
		 */
		public var passId:String;


		/**
		 * 用户密码
		 */
		public var password:String;


		/**
		 * 注册时间(首次登录时间)
		 */
		public function get regTime():int{
			data.position=_regTime;
			return data.readInt();
		}

		/**
		 * 注册时间(首次登录时间)
		 */
		public function set regTime(value:int):void{
			data.position=_regTime=_regTime==0?pos:_regTime;
			data.writeInt(value);
			pos=data.position;
		}
		private var _regTime:int;


		/**
		 * 最近登录时间
		 */
		public function get loginTime():int{
			data.position=_loginTime;
			return data.readInt();
		}

		/**
		 * 最近登录时间
		 */
		public function set loginTime(value:int):void{
			data.position=_loginTime=_loginTime==0?pos:_loginTime;
			data.writeInt(value);
			pos=data.position;
		}
		private var _loginTime:int;


		/**
		 * 最近登录时的IP
		 */
		public function get ip():int{
			data.position=_ip;
			return data.readInt();
		}

		/**
		 * 最近登录时的IP
		 */
		public function set ip(value:int):void{
			data.position=_ip=_ip==0?pos:_ip;
			data.writeInt(value);
			pos=data.position;
		}
		private var _ip:int;
	}
}