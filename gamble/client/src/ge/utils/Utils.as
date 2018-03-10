package ge.utils {
	import flash.utils.ByteArray;

	/**
	 * @author mt-stone
	 */
	public class Utils {
		// 去除字符串头尾空格
		public static function trim(value : String) : String {
			return value.replace(/(^\s+)|(\s+$)/, "");
		}
		
		//是否全数字
		public static function isNumber(value:String):Boolean{
			var pattern:RegExp=/^[0-9]+$/;
			return pattern.test(value)
		}

		// 获得字符串总字符数，中文算两个字符
		public static function getCharCount(value : String) : uint {
			return value.replace(/[^\x00-\xff]/g, "xx").length;
		}

		public static function getUTFLen(value : String) : uint {
			var ba : ByteArray = new ByteArray();
			ba.writeUTFBytes(value);
			return ba.length;
			// 需要减去结束符占用的两位
		}

		public static function DateFormat(second : int) : String {
			var date : Date = new Date(second * 1000);
			return date.getFullYear() + "-" + int(date.getMonth() + 1) + "-" + date.getDate() + "\t" + date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();
		}

		// 时间格式化
		public static function TimeForm(timer : Number) : String {
			var str : String = "";
			var tmp : int;
			tmp = timer / (60 * 60);
			str += orStr(tmp) + ":";
			timer = timer % (60 * 60);
			tmp = timer / (60);
			str += orStr(tmp) + ":";
			timer = timer % (60);
			tmp = timer;
			str += orStr(tmp) + "";
			return str;
		}

		private static function orStr(n : Number) : String {
			return n < 10 ? "0" + n : n.toString();
		}

		/**缩写字符串方法。只显示value < =X长度的字符串，超出X长度的字符用…来表示。
		 * @param value:String	要缩写的字符串。
		 * @param X:int			依据X的长度来判断字符串需不需要缩写（英文占1个字节，中文占2个字节）。
		 * @return:String		返回一个长度为你所设置setup的新字符串。
		 */
		public static function getCharAllOut(value : String, X : int) : String {
			var news : String = "";
			if (getCharCount(value) > X) {
				for (var i : int = 0;i < value.length;i++) {
					var I : String = value.charAt(i);
					if (getCharCount(news + I) <= X - 2) {
						news += I;
					} else {
						news += "…";
						break;
					}
				}
			} else news = value;
			return news;
		}
	}
}