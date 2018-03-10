package game.utils {
	import flash.utils.ByteArray;
	/**
	 * 字符串相关工具
	 * @author weiweimail
	 */
	public class StrUtils {
		
		/**
		 * 计算字符串所含字符数
		 */
		public static function getChars(str:String):int{
			var byteArray:ByteArray=new ByteArray();
			byteArray.writeMultiByte(str, "GBK");
			return byteArray.length;
		}
	}
}
