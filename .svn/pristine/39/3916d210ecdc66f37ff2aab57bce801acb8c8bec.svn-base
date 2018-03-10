package game.data;

import game.data.bean.U_data;
import ge.db.Data;
import ge.db.Fill;
import ge.db.Table;
import ge.log.Log;
import ge.net.Client;

import java.util.HashMap;

public class UserData extends Data {
	private final static Fill initFill = new Fill("init.xml");

	public final Table<U_data> u_data;

	/**
	 * 用户上线后自动推送以下数据
	 */
	public UserData(int userId, Client client) {
		super(userId, client);
		Log.System("Data::Data(" + UserID + ")");

		u_data = new Table<U_data>(log, U_data.class, "userId=" + UserID);
		init();
	}

	/**
	 * 通过init.xml配置初始化用户数据
	 */
	public void Create() {
		// 用init.xml里对应表的配置插入或更新表，里带?号的用下面的值填充
		HashMap<String, Object> var = new HashMap<String, Object>();
		var.put("userId", UserID);
		fill(initFill, var);
		super.run();
	}

	public void load() {
		super.load();
	}

	public String toString() {
		return "UserID:" + UserID;
	}

	public void run() {
		super.run();
		clear();
	}
}
