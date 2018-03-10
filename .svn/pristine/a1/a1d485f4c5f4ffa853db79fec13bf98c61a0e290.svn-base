package ge.db;

import java.io.File;

import ge.log.Log;
import ge.log.LogFile;
import ge.net.Buffer;
import ge.net.Client;
import ge.pthread.SwapThread;

public abstract class Data extends TData {

	public LogFile log;
	protected Client client;

	public final int UserID;

	public Data(int UserID, Client client) {
		this.UserID = UserID;
		this.client = client;
		if (client != null) {
			client.init(this);
		}
		log = new LogFile("userlog" + File.separator + UserID, "log");
	}

	public void load() {
		Log.System("Data::load(" + UserID + ")");
		super.load();
		Client c = client;
		if (c != null) {
			addListener(c);
		}
	}

	public synchronized void clear() {
		if (client == null) {
			Log.System("Data::clear(" + UserID + ") " + new Throwable().getStackTrace()[1].toString());
			if (log != null) {
				log.close();
				log = null;
			}
			super.clear();
		}
	}
	
	public void Send(Buffer buffer) {
		if (client != null) {
			client.Send(buffer);
		}
	}

	/**
	 * 保存数据并清空内存数据
	 */
	public final void dismiss() {
		removeListener(client);
		client = null;
		SwapThread.IT.push(this);
	}
}
