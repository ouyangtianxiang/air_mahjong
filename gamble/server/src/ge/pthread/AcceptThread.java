package ge.pthread;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.util.Iterator;
import java.util.Set;

import ge.Config;
import ge.log.Log;
import ge.net.Channel;

/**
 * 启动服务器
 * 
 * @author txoy
 * 
 */
public class AcceptThread extends Thread {
	private static AcceptThread it;

	public static void Stop() {
		if (it.run) {
			it.run = false;
			it.selector.wakeup();
			Iterator<SelectionKey> iterator = it.selector.keys().iterator();
			while (iterator.hasNext()) {
				try {
					iterator.next().channel().close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			try {
				it.selector.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	public static void Start() {
		it = new AcceptThread();
	}

	private Selector selector = null;

	private String ports[] = Config.get("ServerPort").split(",");

	private AcceptThread() {
		super("Game-AcceptThread");
		Log.Warn(this.getName());
		try {
			selector = Selector.open();
			for (String port : ports) {
				init(Integer.parseInt(port));
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		Log.System("ServerStart");
		start();
	}

	private void init(int port) throws IOException {
		ServerSocketChannel serverSocketChannel;
		serverSocketChannel = ServerSocketChannel.open();
		serverSocketChannel.socket().setReuseAddress(true);
		serverSocketChannel.configureBlocking(false);
		serverSocketChannel.socket().bind(new InetSocketAddress(port));
		serverSocketChannel.register(selector, SelectionKey.OP_ACCEPT, null);
		Log.System("bind:" + port);
	}

	private boolean run = true;

	/**
	 * 线程等待用户连接
	 */
	public void run() {
		while (run) {
			try {
				if (selector.select() == 0)
					continue;
			} catch (IOException e) {
				System.out.println("$" + e.getMessage());
			}
			Set<SelectionKey> readyKeys = selector.selectedKeys();
			Iterator<SelectionKey> it = readyKeys.iterator();
			while (it.hasNext()) {
				SelectionKey key = it.next();
				it.remove();
				ServerSocketChannel channel = (ServerSocketChannel) key.channel();
				try {
					new Channel(channel.accept());
				} catch (Exception e) {
					System.out.println("#" + e.getMessage());
				}
			}
		}
		System.out.println("END:" + this);
	}
}
