package ge.net;

import ge.db.Data;

import java.util.Iterator;

public abstract class Application extends Call {

	private Client client;

	/**
	 * 获得玩家Client
	 * 
	 * @param UserID
	 * @return
	 */
	public Client client(int UserID) {
		return Client.clients.get(UserID);
	}

	/**
	 * 获得所有玩家Client
	 * 
	 * @param UserID
	 * @return
	 */
	public Iterator<Client> clients() {
		return Client.clients.values().iterator();
	}

	final void init(Client client) {
		this.client = client;
		init();
	}

	protected void init() {
	}

	protected void clear() {
	}

	public Client client() {
		return client;
	}

	public Data data() {
		Client c = client;
		return c != null ? c.data() : null;
	}

	public int UserID() {
		Client c = client;
		return c != null ? c.data().UserID : 0;
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
}
