package ge.net;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Method;
import java.util.HashMap;

import game.application.Session;
import ge.annotation.RemoteMethod;

public abstract class Handler extends Call {
	private final static int MAX = 255;
	private final static Method[] METHODS = new Method[MAX];
	private final static Buffer PARAM_TYPE = new Buffer();
	public static HashMap<Class<?>, Byte> pTypes = new HashMap<Class<?>, Byte>();
	static {
		pTypes.put(Buffer.class, (byte) 0);
		pTypes.put(boolean.class, (byte) 1);
		pTypes.put(byte.class, (byte) 2);
		pTypes.put(short.class, (byte) 3);
		pTypes.put(int.class, (byte) 4);
		pTypes.put(long.class, (byte) 5);
		pTypes.put(float.class, (byte) 6);
		pTypes.put(double.class, (byte) 7);
		pTypes.put(String.class, (byte) 8);

		Init();
	}

	public static void Init() {
		System.out.println("++++++");
		PARAM_TYPE.putByte((byte) 4);
		Method(Session.class);
		PARAM_TYPE.flip();
		System.out.println("LoadComplete!!!");
	}

	private static void Method(Class<?> C) {
		Method[] methods = C.getMethods();
		for (Method method : methods) {
			if (method.getDeclaringClass().equals(C)) {
				RemoteMethod rm = method.getAnnotation(RemoteMethod.class);
				if (rm != null) {
					byte v = rm.value();
					System.out.println(C.getResource("") + C.getSimpleName() + "." + method.getName() + "-->" + v);
					if (METHODS[v] != null) {
						throw new Error(METHODS[v].getDeclaringClass().getSimpleName() + "." + METHODS[v].getName() + " AND " + method.getDeclaringClass().getSimpleName() + "." + method.getName() + " @RemoteMethod.value(" + v + ")冲突");
					}
					METHODS[v] = method;
					Parame(v, method);
				}
			}
		}
	}

	private static void Parame(byte code, Method method) {
		PARAM_TYPE.putByte(code);
		Class<?>[] c = method.getParameterTypes();
		PARAM_TYPE.putByte((byte) c.length);
		for (int j = 0; j < c.length; j++) {
			PARAM_TYPE.putByte(pTypes.get(c[j]));
		}
	}

	private static Object[] Parames(Method method, Buffer buffer) {
		Class<?>[] c = method.getParameterTypes();
		Object[] parame = new Object[c.length];
		for (int j = 0; j < c.length; j++) {
			parame[j] = Parame(c[j], buffer);
		}
		return parame;
	}

	private static Object Parame(Class<?> t, Buffer buffer) {
		Object v = null;
		if (t.equals(Buffer.class)) {
			v = buffer;
		} else if (t.equals(boolean.class)) {
			v = buffer.getBoolean();
		} else if (t.equals(byte.class)) {
			v = buffer.getByte();
		} else if (t.equals(short.class)) {
			v = buffer.getShort();
		} else if (t.equals(int.class)) {
			v = buffer.getInt();
		} else if (t.equals(long.class)) {
			v = buffer.getLong();
		} else if (t.equals(float.class)) {
			v = buffer.getFloat();
		} else if (t.equals(double.class)) {
			v = buffer.getDouble();
		} else if (t.equals(String.class)) {
			v = buffer.getUTF();
		} else {
			throw new Error("不支持的类型：" + t.getSimpleName());
		}
		return v;
	}

	public Client client;

	public final void init(Client client) {
		this.client = client;
		PARAM_TYPE.reset();
		client.Send(PARAM_TYPE);
	}

	protected void clear() {
	}

	public void Send(Buffer buffer) {
		Client c = client;
		if (c != null) {
			c.Send(buffer);
		}
	}

	final void close() {
		clear();
		client = null;
	}

	// ---------------------------------------

	public void handler(Buffer buffer) {
		byte code = buffer.getByte();
		if (METHODS[code] == null) {
			System.err.println("不存在的方法(" + code + ")");
			return;
		}
		buffer.mark();
		Method method = METHODS[code];
		try {
			Object[] parames = Parames(method, buffer);
			Object[] result = (Object[]) method.invoke(this, parames);
			if (result != null) {
				buffer.reset();
				buffer.putArray(result);
				buffer.flip();
				client.Send(buffer);
			}
		} catch (Exception e) {
			System.err.println("Handler::handler(" + code + ")" + client);
			try {
				ByteArrayOutputStream byteArray = new ByteArrayOutputStream(1024);
				PrintStream ps = new PrintStream(byteArray);
				e.printStackTrace(ps);
				Buffer buf = new Buffer();
				buf.putByte((byte) 9);// 逻辑报错
				buf.putUTF(byteArray.toString("utf-8"));
				buf.flip();
				client.Send(buf);
			} catch (UnsupportedEncodingException e1) {
				e1.printStackTrace();
			}
			e.printStackTrace();
		}
	}
}
