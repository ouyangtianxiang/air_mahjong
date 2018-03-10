package ge.net.type {
	/**
	 * @author Administrator
	 */
	public class Code {
		private var value : int;

		public function Code(value : int) {
			this.value = value;
		}

		public function valueOf() : int {
			return value;
		}

		public function toString() : String {
			return "new Code("+value+")";
		}
	}
}
