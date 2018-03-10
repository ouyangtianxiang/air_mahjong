package game.data;

import ge.db.Fill;
import ge.db.TData;
import ge.db.Table;

import java.util.HashMap;

public class SystemData extends TData {
	public final static Fill systemFill = new Fill("system.xml");

	public final static SystemData data = new SystemData();

	// public final Table<S_gene> s_gene;

	/**
	 * 用户上线后自动推送以下数据
	 */
	private SystemData() {
		// s_gene = new Table<S_gene>(S_gene.class);
		init();
		load();

		fill(systemFill, new HashMap<String, Object>());
	}
}
