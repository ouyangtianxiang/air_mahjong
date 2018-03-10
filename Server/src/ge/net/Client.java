package ge.net;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.Map;

import javax.websocket.EndpointConfig;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import ge.utils.Util;

@ServerEndpoint(value = "/websocket2", configurator = WSConfigurator.class)
public class Client extends Call {

	Session session;
	Handler handler;

	public String addr;
	public String host;
	public int port;
	public int ip;

	@OnOpen
	public void onOpen(Session session, EndpointConfig config) {
		this.session = session;
		Map<String, Object> map = config.getUserProperties();
		addr = (String) map.get("RemoteAddr");
		host = (String) map.get("RemoteHost");
		port = (int) map.get("RemotePort");
		ip = Util.NumberIP(host);

		handler = new game.application.Session();
		handler.init(this);

		long time = System.currentTimeMillis();
		call((byte) 5, time, "连接成功@@@#");
		System.out.println("Client connected " + addr + " " + host + " " + port);
	}

	public String toString() {
		return host + ":" + port;
	}

	public void Send(Buffer buffer) {
		try {
			if (session.isOpen()) {
				int limit = buffer.limit();
				session.getBasicRemote().sendBinary(buffer.getData());
				buffer.limit(limit);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	@OnMessage
	public void onMessage(ByteBuffer message) {
		try {
			Buffer buffer = new Buffer(message);
			handler.handler(buffer);
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
	}

	@OnMessage
	public void onMessage(String message, Session session) throws IOException, InterruptedException {
		System.out.println(Thread.currentThread());
		System.out.println("String2: " + message + "Session" + session.hashCode());
		session.getBasicRemote().sendText("This is the first server message");
	}

	@OnClose
	public void onClose(Session session) {
		System.out.println("Connection closed" + "Session" + session.isSecure() + " " + session.isOpen());
		try {
			handler.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		System.out.println("(-)" + addr + " " + host + " " + port);
	}

	@OnError
	public void onError(Session session, Throwable error) {
		System.out.println("发生错误" + "Session" + session.hashCode() + " " + error.getMessage());
		// error.printStackTrace();
	}
}
