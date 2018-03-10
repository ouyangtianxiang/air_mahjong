package game.utils;

import java.util.Random;

public class Utils {
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
}
