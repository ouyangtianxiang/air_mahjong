package ge.utils;

//import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

public class TimeUtils {

	/**
	 * 获得当前时间戳
	 */
	public static int getCurTimestamp() {
		return (int) (System.currentTimeMillis() / 1000);
	}

	/**
	 * 获得当前日期时间戳
	 * 
	 * @return
	 */
	public static int getCurDateTimestamp() {
		try {
			String curDate = getCurDateToString();
			return dateToTimestamp(curDate, "yyyy-MM-dd");
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}
	}

	/**
	 * 以yyyy-MM-dd形式返回当前日期
	 * 
	 * @return
	 */
	public static String getCurDateToString() {
		Calendar c = Calendar.getInstance();
		c.setTimeInMillis(System.currentTimeMillis());
		int year = c.get(Calendar.YEAR);
		int month = c.get(Calendar.MONTH) + 1;
		int day = c.get(Calendar.DAY_OF_MONTH);
		return year + "-" + month + "-" + day;
	}

	/**
	 * 返回指定日期的时间戳
	 * 
	 * @throws ParseException
	 * @throws NumberFormatException
	 */
	public static int dateToTimestamp(String date) {
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
		int curDate = 0;
		try {
			curDate = Integer.parseInt(String.valueOf(simpleDateFormat.parse(date).getTime() / 1000));
		} catch (Exception e) {
			e.printStackTrace();
		}
		return curDate;
	}

	/**
	 * 获取2个时间戳之间间隔天数，只取日期怱略时分秒
	 * 
	 * @param timestamp
	 * @param timestamp2
	 * @return
	 * @throws NumberFormatException
	 * @throws ParseException
	 */
	public static int intervalDay(int timestamp, int timestamp2) {
		try {
			String date1 = timestampToDate(timestamp, "yyyy-MM-dd");
			String date2 = timestampToDate(timestamp2, "yyyy-MM-dd");
			int temp = dateToTimestamp(date1, "yyyy-MM-dd") - dateToTimestamp(date2, "yyyy-MM-dd");
			return temp / dayToSecond(1);
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}
	}

	/**
	 * 时间戳按指定模式转日期
	 * 
	 * @param timestamp
	 * @param pattern
	 *            yyyy-MM-dd or yyyy-MM-dd HH:mm:ss
	 * @return
	 */
	public static String timestampToDate(int timestamp, String pattern) {
		SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
		return simpleDateFormat.format(new Date(Long.parseLong(String.valueOf(timestamp)) * 1000));
	}

	/**
	 * 日期按对应模式转时间戳
	 * 
	 * @param date
	 * @param pattern
	 *            yyyy-MM-dd or yyyy-MM-dd HH:mm:ss
	 * @return
	 * @throws NumberFormatException
	 * @throws ParseException
	 */
	public static int dateToTimestamp(String date, String pattern) {
		try {
			SimpleDateFormat simpleDateFormat = new SimpleDateFormat(pattern);
			return Integer.parseInt(String.valueOf(simpleDateFormat.parse(date).getTime() / 1000));
		} catch (Exception e) {
			e.printStackTrace();
			return 0;
		}
	}

	/**
	 * 获取天数对应的秒数
	 * 
	 * @param day
	 * @return
	 */
	public static int dayToSecond(int day) {
		return day * 24 * 60 * 60;
	}

	/**
	 * 两个时间戳是否为同一天
	 * 
	 * @param timestamp
	 * @param timestamp2
	 * @return
	 */
	public static boolean isSameDate(int timestamp, int timestamp2) {
		return intervalDay(timestamp, timestamp2) == 0;
	}

	public static int getYear(int timestamp) {
		Calendar c = Calendar.getInstance();
		c.setTimeInMillis((long) timestamp * (long) 1000);
		return c.get(Calendar.YEAR);
	}

	public static int getMonth(int timestamp) {
		Calendar c = Calendar.getInstance();
		c.setTimeInMillis((long) timestamp * (long) 1000);
		return c.get(Calendar.MONTH) + 1;
	}

	public static int getDay(int timestamp) {
		Calendar c = Calendar.getInstance();
		c.setTimeInMillis((long) timestamp * (long) 1000);
		return c.get(Calendar.DAY_OF_MONTH);
	}

	/**
	 * 获得时间截的月份对应最大天数
	 */
	public static int getMonthDays(int timestamp) {
		Calendar c = Calendar.getInstance();
		c.setTimeInMillis((long) timestamp * (long) 1000);
		return c.getActualMaximum(Calendar.DAY_OF_MONTH);
	}

	// /**
	// * 获得本周一的时间戳
	// */
	// public static int getCurWeekMondayTimestamp(){
	// //指定时区
	// Calendar calendar=Calendar.getInstance(Locale.CHINA);
	// //设置一星期的第一天为周一
	// calendar.setFirstDayOfWeek(Calendar.MONDAY);
	// //设置此Calendar的当前时间值
	// calendar.setTimeInMillis(System.currentTimeMillis());
	// //将给定的日历字段设置为给定值
	// calendar.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
	// int year = calendar.get(Calendar.YEAR);
	// int month = calendar.get(Calendar.MONTH) + 1;
	// int day = calendar.get(Calendar.DAY_OF_MONTH);
	// return dateToTimestamp(year + "-" + month + "-" + day);
	// }

	/**
	 * 获得周一的0点时间戳
	 */
	public static int getMondayTimestamp(int timestamp) {
		String date = timestampToDate(timestamp, "yyyy-MM-dd");
		int dateTimestamp = dateToTimestamp(date, "yyyy-MM-dd");
		int dayOfWeek = getCalendarFieldValue(dateTimestamp, Calendar.DAY_OF_WEEK);
		return dayOfWeek == 1 ? dateTimestamp : dateTimestamp - dayToSecond(dayOfWeek - 1);
	}
	
	/**
	 * 获得整点时间戳
	 */
	public static int getHourTimestamp(int timestamp) {
		Calendar calendar = Calendar.getInstance();
		calendar.setTimeInMillis((long) timestamp * (long) 1000);
		int minute = calendar.get(Calendar.MINUTE);
		int second = calendar.get(Calendar.SECOND);
		return timestamp - minute * 60 - second;
	}

	/**
	 * 获取指定时间戳的指定字段值 Calendar.YEAR Calendar.MONTH Calendar.DAY_OF_MONTH
	 * Calendar.HOUR_OF_DAY Calendar.MINUTE Calendar.SECOND Calendar.DAY_OF_WEEK
	 * 周一到周日返回的值为1-7
	 */
	public static int getCalendarFieldValue(int timestamp, int fieldName) {
		Calendar calendar = Calendar.getInstance();
		calendar.setTimeInMillis((long) timestamp * (long) 1000);
		if (fieldName == Calendar.MONTH) {
			return calendar.get(fieldName) + 1;
		}
		if (fieldName == Calendar.DAY_OF_WEEK) {
			int dayOfWeek = calendar.get(fieldName);
			return dayOfWeek == 1 ? 7 : dayOfWeek - 1;// dayOfWeek=1时表示周日所以转成7
		} else {
			return calendar.get(fieldName);
		}
	}

}
