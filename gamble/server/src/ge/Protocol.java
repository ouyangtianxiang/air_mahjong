package ge;

import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.reflect.Field;

import ge.log.Log;

public class Protocol {

	public Protocol(Class<?> c, String java, String as) {
		try {
			Field[] f_arr = c.getDeclaredFields();
			Log.System("生成Protocol.java开始");
			createFile(java, getJavaCode(f_arr));
			Log.System("生成Protocol.java结束");
			Log.System("生成Protocol.as开始");
			createFile(as, getAsCode(f_arr));
			Log.System("生成Protocol.as结束");
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	private void createFile(String fileName, String code) throws IOException {
		FileOutputStream fos = new FileOutputStream(fileName);
		fos.write(code.getBytes("utf-8"));
		fos.close();
	}

	private String getAsCode(Field[] f_arr) {
		String str = "package game.utils {\r\n";
		str += "\r\n";
		str += "\tpublic class Protocol {\r\n";
		for (int i = 0; i < f_arr.length; i++) {
			String name = f_arr[i].getName().toUpperCase();
			int n = i + 10;
			str += "\t\tpublic static const " + name + ":int=" + n + ";\r\n";
		}
		str += "\t}\r\n";
		str += "}";
		return str;
	}

	private String getJavaCode(Field[] f_arr) {
		String str = "package game.utils;\r\n";
		str += "\r\n";
		str += "public interface Protocol {\r\n";
		for (int i = 0; i < f_arr.length; i++) {
			str += "\tint " + f_arr[i].getName().toUpperCase() + "=" + (i + 10) + ";\r\n";
		}
		str += "}";
		return str;
	}
}
