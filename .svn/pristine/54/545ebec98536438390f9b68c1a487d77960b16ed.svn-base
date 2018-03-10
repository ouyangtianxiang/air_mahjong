package ge.net;

import ge.db.Data;
import ge.log.Log;

import java.lang.reflect.Method;
import java.util.Iterator;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentLinkedQueue;

public class Client extends Call {
	public final static ConcurrentHashMap<Integer, Client> clients = new ConcurrentHashMap<Integer, Client>();
	private final static ConcurrentLinkedQueue<Client> tmps = new ConcurrentLinkedQueue<Client>();

	private ConcurrentHashMap<String, Application> applications = new ConcurrentHashMap<String, Application>();

	public final String ip;
	public final int port;
	private Data data;
	private Channel channel = null;
	private long time = System.currentTimeMillis();

	public Client(Channel channel) {
		this.channel = channel;
		ip = channel.ip;
		port = channel.port;
		Handler.send(this);
		call(5, time);

		for (Client c = tmps.peek(); c != null && c.time + 3000 < time; c = tmps.peek()) {
			// 清除死连接
			c.close();
		}
		tmps.add(this);
	}

	public void accept() {
		tmps.remove(this);
	}

	public String toString() {
		return ip + ":" + port + "(" + data + ")";
	}

	public void init(Data data) {
		this.data = data;
		clients.put(data.UserID, this);
		Log.Warn("(+)", clients.size(), data);
	}

	public void Send(Buffer buffer) {
		if (channel != null) {
			channel.Send(buffer);
		}
	}

	public Data data() {
		System.out.println("data------"+data);
		return data;
	}

	synchronized Application app(Method method) throws Exception {
		Class<?> C = method.getDeclaringClass();
		String className = C.getSimpleName();
		Application app = null;
		if (applications != null) {
			app = applications.get(className);
			if (app == null) {
				app = (Application) C.newInstance();
				app.init(this);
				applications.put(className, app);
			}
		}
		return app;
	}

	public void handler(Buffer buffer) throws Exception {
		buffer.position(0);
		new Handler(this, buffer);
	}

	/**
	 * 断开连接
	 */
	public synchronized void close() {
		Channel ch = channel;
		channel = null;
		if (ch != null) {
			ch.close();
		}
		accept();
		if (applications != null) {
			Iterator<Application> it = applications.values().iterator();
			while (it.hasNext()) {
				try {
					it.next().close();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			applications.clear();
			applications = null;
		}
		if (data != null) {
			clients.remove(data.UserID);
			Log.Warn("(-)", clients.size(), data);
			data.dismiss();
			data = null;
		}
	}

	public synchronized void log(boolean open, int code, Object... parames) {
		if (data != null) {
			data.log.put(open, code, parames);
		}
	}
}
