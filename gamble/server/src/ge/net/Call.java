package ge.net;

public abstract class Call implements Sync {

	/**
	 * @param parameter
	 *            :支持的类型(Byte,Short,Integer,Float,Double,String,Buffer)
	 * @return Object[]
	 */
	public static Object[] Result(Object... parameter) {
		return parameter;
	}

	private Buffer buffer = new Buffer(64);

	public synchronized void call(int code, Object... objects) {
		buffer.clear();
		buffer.putCode(code);
		buffer.putArray(objects);
		buffer.flip();
		Send(buffer);
	}
}
