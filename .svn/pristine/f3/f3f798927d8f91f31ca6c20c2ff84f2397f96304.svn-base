package ge.net {
	/**
	 * @author Administrator
	 */
	public class Where {
		public static function toWhere(str : Array) : Array {
			var where : Array = new Array;
			for (var i : int = 0; i < str.length; i++) {
				where[i] = new Where(str[i]);
			}
			return where;
		}

		private var i : String;
		private var k : String;
		private var v : String;

		public function Where(where : String) {
			var kv : Array = null;
			kv = where.split("!");
			if (kv != null && kv.length == 2) {
				i = '!';
				k = kv[0];
				v = kv[1];
				return;
			}
			kv = where.split("=");
			if (kv != null && kv.length == 2) {
				i = '=';
				k = kv[0];
				v = kv[1];
				return;
			}
			kv = where.split("<");
			if (kv != null && kv.length == 2) {
				i = '<';
				k = kv[0];
				v = kv[1];
				return;
			}
			kv = where.split(">");
			if (kv != null && kv.length == 2) {
				i = '>';
				k = kv[0];
				v = kv[1];
				return;
			}
		}

		public function fairly(o : Bean) : Boolean {
			var value : * = o[k];
			switch (i) {
				case '!':
					return (value != v);
				case '=':
					return (value == v);
				case '<':
					return (value < v);
				case '>':
					return (value > v);
				default:
					return false;
			}
		}
	}
}
