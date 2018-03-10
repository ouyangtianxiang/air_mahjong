package ge.net;

import ge.annotation.Exclude;
import ge.annotation.RemoteMethod;
import ge.application.SystemApplication;
import ge.log.Log;
import ge.pthread.SwapThread;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Method;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.concurrent.ConcurrentHashMap;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

public class Handler implements Runnable {
	private final static int MAX = 255;
	private final static Method[] METHODS = new Method[MAX];
	private final static Buffer PARAM_TYPE = new Buffer();
	private final static boolean[] LOG = new boolean[MAX];

	public static synchronized void send(Client client) {
		PARAM_TYPE.reset();
		client.Send(PARAM_TYPE);
	}

	public static void init(Object obj) {
		PARAM_TYPE.putCode(4);
		String classPath = obj.getClass().getProtectionDomain().getCodeSource().getLocation().getPath();
		Log.System("LoadApplication......", classPath);
		Method(SystemApplication.class);
		File file = new File(classPath);
		if (file.isFile()) {
			JarFile jarFile;
			try {
				jarFile = new JarFile(file);
				Enumeration<JarEntry> entrys = jarFile.entries();
				while (entrys.hasMoreElements()) {
					JarEntry jarEntry = entrys.nextElement();
					loadApp(jarEntry.getName());
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		} else {
			dir(file.listFiles());
		}
		PARAM_TYPE.flip();
		Log.System("LoadComplete!!!");
	}

	private static void dir(File[] files) {
		for (File file : files) {
			if (file.isDirectory()) {
				dir(file.listFiles());
			} else {
				loadApp(file.getPath());
			}
		}
	}

	private static void loadApp(String path) {
		try {
			path = path.replaceAll("\\\\", ".");
			path = path.replaceAll("/", ".");
			int begin = path.indexOf("game.application");
			int end = path.indexOf(".class");
			if (begin != -1 && end != -1) {
				path = path.substring(begin, end);
				Class<?> C = Class.forName(path);
				Method(C);
			}
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}

	private static void Method(Class<?> C) {
		if (C.getSuperclass().equals(Application.class)) {
			Method[] methods = C.getMethods();
			for (Method method : methods) {
				if (method.getDeclaringClass().equals(C)) {
					RemoteMethod rm = method.getAnnotation(RemoteMethod.class);
					if (rm != null) {
						int v = rm.value();
						Log.System(C.getResource("") + C.getSimpleName() + "." + method.getName(), "-->", v);
						if (METHODS[v] != null) {
							throw new Error(METHODS[v].getDeclaringClass().getSimpleName() + "." + METHODS[v].getName() + " AND " + method.getDeclaringClass().getSimpleName() + "." + method.getName() + " @RemoteMethod.value(" + v + ")冲突");
						}
						METHODS[v] = method;
						Parame(v, method);
						Exclude exclude = method.getAnnotation(Exclude.class);
						LOG[v] = exclude == null;
					}
				}
			}
		}
	}

	private static void Parame(int code, Method method) {
		PARAM_TYPE.putCode(code);
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
		} else if (t.equals(Boolean[].class)) {
			v = array(new Boolean[buffer.getUByte()], boolean.class, buffer);
		} else if (t.equals(Byte[].class)) {
			v = array(new Byte[buffer.getUByte()], byte.class, buffer);
		} else if (t.equals(Short[].class)) {
			v = array(new Short[buffer.getUByte()], short.class, buffer);
		} else if (t.equals(Integer[].class)) {
			v = array(new Integer[buffer.getUByte()], int.class, buffer);
		} else if (t.equals(Long[].class)) {
			v = array(new Long[buffer.getUByte()], long.class, buffer);
		} else if (t.equals(Float[].class)) {
			v = array(new Float[buffer.getUByte()], float.class, buffer);
		} else if (t.equals(Double[].class)) {
			v = array(new Double[buffer.getUByte()], double.class, buffer);
		} else if (t.equals(String[].class)) {
			v = array(new String[buffer.getUByte()], String.class, buffer);
		} else {
			throw new Error("不支持的类型：" + t.getSimpleName());
		}
		return v;
	}

	private static HashMap<Class<?>, Byte> pTypes = new HashMap<Class<?>, Byte>();
	static {
		pTypes.put(Buffer.class, (byte)0);
		pTypes.put(boolean.class, (byte)1);
		pTypes.put(byte.class, (byte)2);
		pTypes.put(short.class, (byte)3);
		pTypes.put(int.class, (byte)4);
		pTypes.put(long.class, (byte)5);
		pTypes.put(float.class, (byte)6);
		pTypes.put(double.class, (byte)7);
		pTypes.put(String.class, (byte)8);

		pTypes.put(Boolean[].class, (byte)11);
		pTypes.put(Byte[].class, (byte)12);
		pTypes.put(Short[].class, (byte)13);
		pTypes.put(Integer[].class, (byte)14);
		pTypes.put(Long[].class, (byte)15);
		pTypes.put(Float[].class, (byte)16);
		pTypes.put(Double[].class, (byte)17);
		pTypes.put(String[].class, (byte)18);
	}

	private static Object array(Object[] a, Class<?> c, Buffer buffer) {
		int n = a.length;
		for (int i = 0; i < n; i++) {
			a[i] = Parame(c, buffer);
		}
		return a;
	}

	// ---------------------------------------
	private Client client;
	private Buffer buffer;
	private int code;

	public Handler(Client client, Buffer buffer) {
		code = buffer.getCode();
		if (METHODS[code] == null) {
			System.err.println("不存在的方法(" + code + ")");
			return;
		}
		this.client = client;
		this.buffer = buffer;
		SwapThread.IT.push(this);
	}

	public final static ConcurrentHashMap<Thread, Integer> thmethod = new ConcurrentHashMap<Thread, Integer>();

	public void run() {
		buffer.mark();
		Method method = METHODS[code];
		try {
			Application app = client.app(method);
			if (app != null) {
				Object[] parames = Parames(method, buffer);
				if (LOG[code]) {
					client.log(true, code, parames);
				}
				thmethod.put(Thread.currentThread(), code);
				Object[] result = (Object[]) method.invoke(app, parames);
				if (LOG[code]) {
					client.log(false, code);
				}
				if (result != null) {
					buffer.reset();
					buffer.putArray(result);
					buffer.flip();
					client.Send(buffer);
				}
			}
		} catch (Exception e) {
			System.err.println("Handler::handler(" + code + ")" + client);
			try {
				ByteArrayOutputStream byteArray = new ByteArrayOutputStream(1024);
				PrintStream ps = new PrintStream(byteArray);
				e.printStackTrace(ps);
				Buffer buffer = new Buffer();
				buffer.putCode(9);// 逻辑报错
				buffer.putUTF(byteArray.toString("utf-8"));
				buffer.flip();
				client.Send(buffer);
			} catch (UnsupportedEncodingException e1) {
				e1.printStackTrace();
			}
			e.printStackTrace();
		} finally {
			client = null;
			buffer = null;
		}
	}
}
