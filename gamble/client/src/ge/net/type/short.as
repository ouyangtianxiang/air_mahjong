package ge.net.type {
	/**
	 * @author Administrator
	 */
	public class short {
		private var value : int;

		public function short(value : int) {
			this.value = value;
		}

		public function valueOf() : int {
			return value;
		}

		public function toString() : String {
			return "new short("+value+")";
		}
	}
}
