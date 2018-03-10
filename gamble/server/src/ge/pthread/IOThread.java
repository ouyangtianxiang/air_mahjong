package ge.pthread;

import java.io.IOException;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.SocketChannel;
import java.util.Iterator;
import java.util.Set;

import ge.log.Log;
import ge.net.Channel;

/**
 * @author txoy
 */
public class IOThread extends Thread {
	private static byte cpu;
	private static IOThread it[];
	private static byte c = 0;

	public static void Init() {
		cpu = (byte) Runtime.getRuntime().availableProcessors();
		it = new IOThread[cpu];
		for (int i = 0; i < cpu; i++) {
			try {
				it[i] = new IOThread("Game-IOThread-" + i);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	public static IOThread Read() {
		return it[c++ & 0xFF % cpu];
	}

	public Selector selector = null;

	private Object gate = new Object();

	private IOThread(String name) throws IOException {
		super(name);
		Log.Warn(this.getName());
		selector = Selector.open();
		start();
	}

	/**
	 * 增加通道 *
	 * 
	 * @param socketChannel
	 * @return
	 */
	public SelectionKey addChannel(SocketChannel socketChannel, int ops, Channel channle) {
		try {
			synchronized (gate) {
				selector.wakeup();
				return socketChannel.register(selector, ops, channle);
			}
		} catch (IOException e) {
			e.printStackTrace();
			return null;
		}
	}

	private boolean run = true;

	/**
	 * 线程接收信息
	 */
	public void run() {
		while (run) {
			synchronized (gate) {
			}
			try {
				if (selector.select() == 0) {
					continue;
				}
			} catch (IOException e) {
				System.out.println("@" + e.getMessage());
			}
			Set<SelectionKey> readyKeys = selector.selectedKeys();
			Iterator<SelectionKey> it = readyKeys.iterator();
			while (it.hasNext()) {
				SelectionKey key = it.next();
				it.remove();
				Channel channle = (Channel) key.attachment();
				try {
					if (key.isWritable()) {
						channle.write();
					}
					if (key.isReadable()) {
						channle.read();
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
		System.out.println("END:" + this);
	}
}
