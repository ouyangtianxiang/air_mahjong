package game.room;

import game.application.NCMJ;
import game.data.bean.T_brand;
import game.data.bean.T_state;
import ge.db.Table;

import java.util.Iterator;
import java.util.concurrent.ConcurrentHashMap;

public class RoomMahJong extends RoomBase {

	protected static ConcurrentHashMap<Integer, RoomMahJong> ROOMS = new ConcurrentHashMap<Integer, RoomMahJong>();

	public static RoomMahJong Find(int roomId) {
		RoomMahJong room = ROOMS.get(roomId);
		return room;
	}

	private synchronized static int CreataID() {
		int id = 0;
		do {
			id = (int) (100000 + Math.random() * 900000);
		} while (ROOMS.containsKey(id));
		return id;
	}

	static byte[] BRAND = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 24, 25, 26, 27, 28, 29, 31, 32, 33, 34, 36, 37, 38 };

	private Table<T_brand> t_brand = new Table<T_brand>(T_brand.class, null);
	private Table<T_state> t_state = new Table<T_state>(T_state.class, null);

	public RoomMahJong(int size) {
		super(CreataID(), size);
		ROOMS.put(roomId, this);

		short id = 1;
		for (byte b : BRAND) {
			for (int i = 0; i < 4; i++) {
				new T_brand(t_brand, id++, b, (byte) 0, (byte) 0);
			}
		}
	}

	public void into(NCMJ mj) {
		super.into(mj);
		t_brand.addListener(mj);
		t_state.addListener(mj);
		new T_state(t_state, mj.userId, mj.index, (byte) 0);
	}

	public void exit(NCMJ mj) {
		remove(mj);
		t_state.del(mj.userId);
	}

	/**
	 * 准备
	 */
	public void prepare(NCMJ mj) {
		T_state ts = t_state.get(mj.userId);
		ts.state = 1;
		ts.update();

		Iterator<T_state> it = t_state.it();
		while (it.hasNext()) {
			if (it.next().state == 0) {
				return;
			}
		}
		startGame();
	}

	/**
	 * 出牌
	 */
	public void play(NCMJ mj, short id) {

	}

	/**
	 * 应牌
	 */
	public void reply(NCMJ mj, short id) {

	}

	private void startGame() {

	}
}