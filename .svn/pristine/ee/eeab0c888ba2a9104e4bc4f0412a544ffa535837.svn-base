package ge.log;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.io.UnsupportedEncodingException;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.channels.FileChannel.MapMode;
import java.text.SimpleDateFormat;
import java.util.Date;

public class LogFile {

	private static final SimpleDateFormat DATE = new SimpleDateFormat("yyyy-MM-dd");
	private static final SimpleDateFormat TIME = new SimpleDateFormat("HH-mm-ss");
	private static final SimpleDateFormat TIMES = new SimpleDateFormat("HH:mm:ss:SSS ");

	private static final long SIZE = 1024 * 1024 * 1;
	private String suffix;
	private MappedByteBuffer buffer;
	private String dir;

	public LogFile(String dir, String suffix) {
		this.dir = dir;
		this.suffix = suffix;
	}

	private void init() {
		try {
			close();
			Date d = new Date();
			String date = DATE.format(d);
			String time = TIME.format(d);
			File f = new File(dir + File.separatorChar + date, time + "." + suffix);
			f.getParentFile().mkdirs();
			RandomAccessFile file = new RandomAccessFile(f, "rwd");
			FileChannel channel = file.getChannel();
			buffer = channel.map(MapMode.READ_WRITE, 0, SIZE);
			channel.close();
			file.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void close() {
		if (buffer != null) {
			buffer.force();
			buffer.clear();
			buffer = null;
		}
		System.gc();
	}

	public void put(int b) {
		if (buffer == null || buffer.remaining() == 0) {
			init();
		}
		buffer.put((byte) b);
	}

	public void put(String str) {
		try {
			byte[] b = str.getBytes("UTF-8");
			for (byte c : b) {
				put(c);
			}
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
	}

	private boolean open;

	public void put(int code, Object... parames) {
		if (open) {
			if (code > 0) {
				put("\r\n");
				put(String.valueOf(code) + ":");
			}
			for (Object o : parames) {
				put(o + " ");
			}
		}
	}

	public void put(boolean open, int code, Object[] parames) {
		this.open = open;
		if (open) {
			put("\r\n\r\n");
			byte[] time = TIMES.format(new Date()).getBytes();
			for (byte c : time) {
				put(c);
			}
			put(code, parames);
		}
	}
}
