package ge.log;

import ge.Config;

import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintStream;
import java.text.SimpleDateFormat;
import java.util.Date;

public class Log extends OutputStream {

	private static final SimpleDateFormat TIMES = new SimpleDateFormat("HH:mm:ss:SSS ");

	private static final String dir = "log";

	private static int TO = 3;
	private static int LV = 4;

	/**
	 * 
	 * @param lv
	 *            (0:Fatal,1:Error,2:Warn,3:System,4:Info,5:Debug)
	 * @param to
	 *            (0:not,1:file,2:console,3:file+console)
	 */
	public static void Init() {
		String log = Config.get("log");
		if (log != null) {
			TO = Integer.valueOf("" + log.charAt(0));
			LV = Integer.valueOf("" + log.charAt(1));
		}
		System.setOut(new PrintStream(new Log(System.out)));
		System.setErr(new PrintStream(new Log(System.err)));
	}

	private static LogFile logFile = new LogFile(dir, "log");
	private PrintStream out;

	private Log(PrintStream out) {
		this.out = out;
	}

	private boolean rn = true;

	public void write(int b) throws IOException {
		if (rn) {
			rn = false;
			byte[] time = TIMES.format(new Date()).getBytes();
			for (byte c : time) {
				write(c);
			}
		}
		if ((TO & 1) > 0) {
			logFile.put((byte) b);
		}
		if ((TO & 2) > 0) {
			out.write(b);
		}
		rn = b == 10;
	}

	private static void print(PrintStream out, int lv, Object... message) {
		if (lv <= LV) {
			synchronized (out) {
				for (Object m : message) {
					out.print(m + " ");
				}
				out.println();
			}
		}
	}

	public static void Debug(Object... message) {
		print(System.out, 5, message);
	}

	public static void Info(Object... message) {
		print(System.out, 4, message);
	}

	public static void System(Object... message) {
		print(System.out, 3, message);
	}

	public static void Warn(Object... message) {
		print(System.err, 2, message);
	}

	public static void Error(Object... message) {
		print(System.err, 1, message);
	}

	public static void Fatal(Object... message) {
		print(System.err, 0, message);
	}
}
