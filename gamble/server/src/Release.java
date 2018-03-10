import game.utils.MD5;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

public class Release {
	private final static String PATH = "E:\\air_mahjong\\gamble\\client\\bin\\";

	public static void main(String[] a) {
		new Release();
	}

	public Release() {

		String version = System.currentTimeMillis() + "";

		VersionInfo();
		SaveFile(PATH + "version", version);

		System.out.println(version);
	}

	static void VersionInfo() {
		String str = dirInfo(PATH);
		SaveFile(PATH + "versionInfo", str);
	}

	static String dirInfo(String filename) {
		return dirInfo(new File(filename));
	}

	static String dirInfo(File dir) {
		if (dir.getName().equals(".svn")) {
			return "";
		}
		String str = "";
		File[] files = dir.listFiles();
		if (files != null) {
			for (File file : files) {
				if (file.isDirectory()) {
					str += dirInfo(file);
				} else {
					str += toStr(file);
				}
			}
		}
		return str;
	}

	private static String[] ex = { ".xml", ".atf", ".mp3", ".swf" };

	private static String toStr(File file) {
		String name = file.getPath();
		for (String e : ex) {
			if (name.endsWith(e)) {
				return name.substring(PATH.length()).replaceAll("\\\\", "/") + "," + Kye(file) + "," + file.length() + "\n";
			}
		}
		return "";
	}

	static String Kye(File file) {
		int len = Math.min(1024 * 64, (int) file.length());
		byte[] bytes = new byte[len];
		FileInputStream is;
		try {
			is = new FileInputStream(file);
			is.read(bytes);
			is.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return MD5.getMD5(bytes);
	}

	static void SaveFile(String fileName, String txt) {
		try {
			FileOutputStream file = new FileOutputStream(fileName);
			file.write(txt.getBytes("UTF-8"));
			file.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
