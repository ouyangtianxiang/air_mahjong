package game.utils {
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import game.modules.window.WindowMessage;
	
	/**
	 * @author Administrator
	 */
	public class TimeUtils {
		
		private static var file : File = File.createTempFile();
		private static var fs : FileStream = new FileStream();
		
		public static function verify() : Boolean {
			fs.open(file, FileMode.WRITE);
			var time : Number = new Date().time / 1000;
			var t : Number = file.modificationDate.time / 1000;
			if (Math.abs(t - time) > 5) {
				WindowMessage.it.init("系统时间错误！(5)", function() : void {
					NativeApplication.nativeApplication.exit();
				});
				return false;
			}
			return true;
		}
		
		/**
		 * 计算2个时间戳间隔天数：timestamp1-timestamp2
		 */
		public static function intervalDays(timestamp1 : int, timestamp2 : int) : int {
			var day : int = 24 * 60 * 60;
			return (timestampToDateTimestamp(timestamp1) - timestampToDateTimestamp(timestamp2)) / day;
		}
		
		/**
		 * 剩余时间，根据2个时间差，小时有可能大于23，timestamp1-timestamp2<0时返回""
		 * return 小时:分:秒
		 */
		public static function intervalTimeTOString(timestamp1 : int, timestamp2 : int) : String {
			var str : String = "";
			var remainTime : Number = timestamp1 - timestamp2;
			if (remainTime >= 0) {
				var hour : int = remainTime / (60 * 60);
				var minute : int = (remainTime - hour * 60 * 60) / (60);
				var second : int = (remainTime - hour * 60 * 60 - minute * 60);
				var h : String = hour > 9 ? "" + hour : "0" + hour;
				var m : String = minute > 9 ? "" + minute : "0" + minute;
				var s : String = second > 9 ? "" + second : "0" + second;
				str = h + ":" + m + ":" + s;
			}
			return str;
		}
		
		/**
		 * 剩余时间，根据2个时间差，timestamp1-timestamp2<0时返回""
		 * return 天 小时 分 秒
		 */
		public static function intervalTimeTOString2(timestamp1 : int, timestamp2 : int) : String {
			var str : String = "";
			var remainTime : Number = timestamp1 - timestamp2;
			if (remainTime > 0) {
				var hour : int = remainTime / (60 * 60);
				var minute : int = (remainTime - hour * 60 * 60) / (60);
				var second : int = (remainTime - hour * 60 * 60 - minute * 60);
				str = int(hour / 24) + "天" + hour % 24 + "小时" + minute + "分" + second + "秒";
			}
			return str;
		}
		
		/**
		 * 时间戳转日期:年-月-日
		 */
		public static function timestampToDate(timestamp : int) : String {
			var date : Date = new Date(timestamp * 1000);
			return date.fullYear + "-" + (date.month + 1) + "-" + date.date;
		}
		
		/**
		 * 时间戳转时间:年-月-日 时:分:秒
		 */
		public static function timestampToTime(timestamp : int) : String {
			var date : Date = new Date(timestamp * 1000);
			var h : String = date.hours > 9 ? "" + date.hours : "0" + date.hours;
			var m : String = date.minutes > 9 ? "" + date.minutes : "0" + date.minutes;
			var s : String = date.seconds > 9 ? "" + date.seconds : "0" + date.seconds;
			return date.fullYear + "-" + (date.month + 1) + "-" + date.date + " " + h + ":" + m + ":" + s;
		}
		
		/**
		 * 时间戳转时间:年-月-日 时:分
		 */
		public static function timestampToTime2(timestamp : int) : String {
			var date : Date = new Date(timestamp * 1000);
			var h : String = date.hours > 9 ? "" + date.hours : "0" + date.hours;
			var m : String = date.minutes > 9 ? "" + date.minutes : "0" + date.minutes;
			return date.fullYear + "-" + (date.month + 1) + "-" + date.date + " " + h + ":" + m;
		}
		
		/**
		 * 取时间戳的日期部分返回日期的时间戳
		 */
		public static function timestampToDateTimestamp(timestamp : int) : int {
			var date : Date = new Date(timestamp * 1000);
			var date2 : Date = new Date(date.fullYear, date.month, date.date);
			return Date.parse(date2) / 1000;
		}
		
		/**
		 * 取时间戳的整点时间(去掉分和秒)
		 */
		public static function hourTimestamp(timestamp : int) : int {
			var date : Date = new Date(timestamp * 1000);
			return timestamp - date.minutes * 60 - date.seconds;
		}
		
		/**
		 * 取时间戳的当前周几
		 */
		public static function getDayOfWeek(timestamp : int) : int {
			var date : Date = new Date(timestamp * 1000);
			return date.day == 0 ? 7 : date.day;
		}
		
		/**
		 * 取周一的0点时间戳
		 */
		public static function getMondayTimestamp(timestamp : int) : int {
			var dateTimestamp : int = timestampToDateTimestamp(timestamp);
			var dayOfWeek : int = getDayOfWeek(timestamp);
			return dayOfWeek == 1 ? dateTimestamp : dateTimestamp - (dayOfWeek - 1) * 24 * 60 * 60;
		}
		
		/**
		 * 天数转换成秒
		 */
		public static function dayToSecond(days:int):int{
			return days * 24 * 60 * 60;
		}
		
		/**
		 * 将时间戳的日期部分去掉后转换成秒数
		 */
		public static function getSeconds(timestamp : int):int{
			return timestamp-TimeUtils.timestampToDateTimestamp(timestamp);
		}
		
		public static function timestampToString3(timestamp : int) : String {
			var h : int = Math.floor(timestamp / 3600);
			var m : int = Math.floor(timestamp / 60) % 60;
			var s : int = Math.floor(timestamp % 60);
			
			return (h > 9 ? "" + h : "0" + h) + ":" + (m > 9 ? "" + m : "0" + m) + ":" + (s > 9 ? "" + s : "0" + s);
		}
	
	}
}
