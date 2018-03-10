package ge.utils;

import java.util.Random;

public class Util {

	/**
	 * 随机数
	 * 
	 * @param max
	 * @return 0到max间的随机数
	 */
	public static int random(int max) {
		return (int) (Math.random() * max);
	}

	/**
	 * 随机数
	 * 
	 * @param min
	 * @param max
	 * @return min到max间的随机数
	 */
	public static int random(int min, int max) {
		return (int) Math.round((Math.random() * (max - min)) + min);
	}

	public static String StringIP(int IP) {
		return (IP >> 24 & 0xff) + "." + (IP >> 16 & 0xff) + "." + (IP >> 8 & 0xff) + "." + (IP & 0xff);
	}

	public static int NumberIP(String IP) {
		int[] b = new int[4];
		for (int i = 0, j = 0; i < IP.length(); i++) {
			char c = IP.charAt(i);
			if (c == 46) {
				j++;
			} else {
				b[j] = b[j] * 10 + (c - 48);
			}
		}
		return b[0] << 24 | b[1] << 16 | b[2] << 8 | b[3];
	}

	public static boolean isInnerIP(String ip) {
		// A类:10.0.0.0-10.255.255.255
		if (inner(ip, "10.0.0.0", "10.255.255.255")) {
			return true;
		}
		// B类:172.16.0.0-172.31.255.255
		if (inner(ip, "172.16.0.0", "172.31.255.255")) {
			return true;
		}
		// C类:192.168.0.0-192.168.255.255
		if (inner(ip, "192.168.0.0", "192.168.255.255")) {
			return true;
		}
		// 还有127这个网段是环回地址
		if (inner(ip, "127.0.0.1", "127.0.0.1")) {
			return true;
		}
		return false;
	}

	private static boolean inner(String ip, String begin, String end) {
		int _ip = NumberIP(ip);
		return (_ip >= NumberIP(begin)) && (_ip <= NumberIP(end));
	}

	/**
	 * 置换环境变量
	 * 
	 * @param str
	 * @return
	 */
	public static String Env(String str) {
		while (true) {
			int begin = str.indexOf('{');
			int end = str.indexOf('}');
			if (begin >= 0 && end > begin) {
				String key = str.substring(begin + 1, end);
				String value = System.getenv(key);
				str = str.substring(0, begin) + value + str.substring(end + 1);
			} else {
				break;
			}
		}
		return str;
	}

	/**
	 * 产生不重复的随机数
	 * 
	 * @param sum
	 *            产生随机数的个数
	 * @param range
	 *            产生随机数的范围(0到range-1)
	 * @return
	 */
	public static int[] randomNoRepeat(int sum, int range) {
		int[] arr = new int[sum];
		Random rand = new Random();
		boolean[] bool = new boolean[range];
		int num = 0;
		for (int i = 0; i < sum; i++) {
			do {
				num = rand.nextInt(range);
			} while (bool[num]);
			bool[num] = true;
			arr[i] = num;
		}
		return arr;
	}

	/**
	 * 通过正则表达式获取字符串包含字符数长度，1中文=2字节
	 * 
	 * @param str
	 */
	public static int regexGetCharLen(String str) {
		return str.replaceAll("[\u4e00-\u9fa5]", "xx").length();
	}

	public static String MD5(byte[] source) {
		String s = null;
		char hexDigits[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
		try {
			java.security.MessageDigest md = java.security.MessageDigest.getInstance("MD5");
			md.update(source);
			byte tmp[] = md.digest();
			char str[] = new char[16 * 2];
			int k = 0;
			for (int i = 0; i < 16; i++) {
				byte byte0 = tmp[i];
				str[k++] = hexDigits[byte0 >>> 4 & 0xf];
				str[k++] = hexDigits[byte0 & 0xf];
			}
			s = new String(str);
		} catch (Exception e) {
			// log.warn("",e);
		}
		return s;
	}
}
