package game.data;

import java.util.concurrent.ConcurrentHashMap;

import game.application.Session;
import game.data.bean.U_data;
import game.data.bean.U_info;
import ge.db.Table;

public class Data {

	private static ConcurrentHashMap<Integer, Session> online = new ConcurrentHashMap<Integer, Session>();

	public int UserID = -1;
	private Table<U_data> u_data;
	private Table<U_info> uinfo;
	private U_info u_info;
	public U_data ud;
	private Session session;

	public Data(Session session) {
		this.session = session;
	}

	public void login(String passId, String info) {
		int loginTime = (int) (System.currentTimeMillis() / 1000);
		int ip = session.client.ip;

		uinfo = new Table<U_info>(U_info.class, "passId", passId);
		uinfo.load();
		u_info = uinfo.get();
		if (u_info == null) {
			u_info = new U_info(uinfo, 0, passId, "", loginTime, loginTime, ip);
		}

		u_info.ip = ip;
		u_info.regTime = loginTime;
		u_info.update();
		u_info.save();

		UserID = u_info.id;
	}

	public void load() {
		u_data = new Table<U_data>(U_data.class, "userId", UserID);
		u_data.load();
		ud = u_data.get();
		if (ud == null) {
			ud = new U_data(u_data, u_info.id, (byte) 1, 100, 999, 0);
			ud.save();
		}
		u_data.addListener(session);
	}

	public void gameRoom(int code) {
		ud.roomCode = code;
		ud.update();
	}

	public void clear() {
		u_data.removeListener(session);
	}
}
