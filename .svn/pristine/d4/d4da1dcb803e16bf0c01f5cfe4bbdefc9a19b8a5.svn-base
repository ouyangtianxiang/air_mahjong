package game.data;

import java.util.zip.Deflater;

import game.utils.MD5;
import ge.net.Buffer;
import ge.net.Sync;

public class ST implements Sync {

	public static final ST it = new ST();

	private Buffer buffer = new Buffer();

	private String md5;

	public ST() {

		SystemData.data.Get(this);
		buffer.flip();
		int len = buffer.remaining();
		byte[] inData = new byte[len];
		buffer.data.get(inData);
		System.out.println("len:" + len);
		byte[] outData = new byte[len];
		Deflater deflater = new Deflater();
		deflater.setInput(inData);
		deflater.finish();
		len = deflater.deflate(outData);
		System.out.println("len:" + len);
		buffer.clear();

		md5 = MD5.getMD5(outData);
		buffer.putUTF(md5);
		buffer.data.put(outData, 0, len);
		buffer.flip();
	}

	public void Send(Buffer buffer) {
		this.buffer.putBuffer(buffer);
	}

	public boolean comparison(String md5) {
		return this.md5.equals(md5);
	}

	public Buffer buffer() {
		buffer.reset();
		return buffer;
	}

}
