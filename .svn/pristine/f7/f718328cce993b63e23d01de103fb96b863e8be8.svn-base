package ge.net;

import java.io.IOException;
import java.nio.channels.SelectionKey;
import java.nio.channels.SocketChannel;
import java.util.concurrent.ConcurrentLinkedQueue;

import ge.log.Log;
import ge.pthread.IOThread;
import ge.pthread.SwapThread;

/**
 * 每个客户端的通道
 * 
 * @author txoy
 * 
 */
public class Channel implements Runnable {
	public SocketChannel socketChannel = null;
	public Client client;
	public final String ip;
	public final int port;
	public final int localPort;
	public final String localIp;
	private SelectionKey key;
	private IOThread thread;

	/**
	 * 构造函数据
	 * 
	 * @throws IOException
	 */
	public Channel(SocketChannel socketChannel) throws IOException {
		this.socketChannel = socketChannel;
		socketChannel.configureBlocking(false);
		ip = socketChannel.socket().getInetAddress().getHostAddress();
		port = socketChannel.socket().getPort();
		localIp = socketChannel.socket().getLocalAddress().getHostAddress();
		localPort = socketChannel.socket().getLocalPort();
		client = new Client(this);
		thread = IOThread.Read();
		key = thread.addChannel(socketChannel, SelectionKey.OP_READ, this);
		Log.System("(++){" + ip + ":" + port + "->" + localIp + ":" + localPort + "}");
	}

	private Buffer lenbuf = new Buffer(2);
	private Buffer buffer = null;

	public void read() {
		try {
			while (true) {
				if (buffer == null) {
					lenbuf.clear();
					int i = socketChannel.read(lenbuf.getData());
					if (i == -1) {
						throw new Exception("Exception(len:i == -1)");// 断开连接
					}
					if (lenbuf.remaining() == 0) {
						lenbuf.flip();
						int len = lenbuf.getShort();
						if (len == 0) {
							throw new Exception("Exception(len == 0)");// 断开连接
						}
						buffer = new Buffer(len);
					} else {
						break;
					}
				} else {
					int i = socketChannel.read(buffer.getData());
					if (i == -1) {
						throw new Exception("Exception(data:i == -1)");// 断开连接
					}
					if (buffer.remaining() == 0) {
						buffer.flip();
						client.handler(buffer);
						buffer = null;
					} else {
						break;
					}
				}
			}
		} catch (Exception e) {
			try {
				key.cancel();
			} catch (Exception ex) {
				ex.printStackTrace();
			} finally {
				// 断开连接
				close();
			}
		}
	}

	public void write() {
		synchronized (queue) {
			Buffer buf = queue.peek();
			if (buf != null) {
				send(buf);
				if (buf.remaining() == 0) {
					queue.remove(buf);
				}
			}
			if (queue.isEmpty()) {
				key.interestOps(key.interestOps() & ~SelectionKey.OP_WRITE);
			}
		}
	}

	private ConcurrentLinkedQueue<Buffer> queue = new ConcurrentLinkedQueue<Buffer>();

	private void send(Buffer buffer) {
		try {
			int n;
			do {
				n = socketChannel.write(buffer.getData());
			} while (n > 0 && buffer.remaining() > 0);
		} catch (Exception e) {
			Log.System(e.getMessage());
			close();
		}
	}

	private void SendData(Buffer buffer) {
		synchronized (queue) {
			if (queue.isEmpty()) {
				send(buffer);
			}
			if (buffer.remaining() > 0) {
				Buffer buf = new Buffer(buffer.remaining());
				buf.putBuffer(buffer);
				buf.flip();
				queue.add(buf);
				key.interestOps(key.interestOps() | SelectionKey.OP_WRITE);
				thread.selector.wakeup();
			}
		}
	}

	private Buffer outLenBuf = new Buffer(8);

	public synchronized void Send(Buffer buffer) {
		int len = buffer.remaining();
		outLenBuf.clear();
		if (len > 65535) {
			outLenBuf.putByte((byte) 252);
			outLenBuf.putInt(len);
		} else if (len > 250) {
			outLenBuf.putByte((byte) 251);
			outLenBuf.putShort((short) len);
		} else {
			outLenBuf.putByte((byte) len);
		}
		outLenBuf.flip();
		if (healthy) {
			SendData(outLenBuf);
			SendData(buffer);
		}
	}

	private boolean healthy = true;

	/**
	 * 准备断开连接
	 */
	public void close() {
		if (healthy) {
			healthy = false;
			SwapThread.IT.push(this);
		}
	}

	/**
	 * 断开连接
	 */
	public void run() {
		Log.System("(--){" + ip + ":" + port + "->" + localIp + ":" + localPort + "}");
		if (client != null) {
			client.close();
			client = null;
		}
		try {
			if (socketChannel != null) {
				socketChannel.close();
				socketChannel = null;
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
