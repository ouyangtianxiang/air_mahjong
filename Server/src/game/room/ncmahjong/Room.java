package game.room.ncmahjong;

import java.util.Comparator;
import java.util.Timer;
import java.util.Vector;

import game.application.Session;
import game.data.bean.T_state;
import game.data.bean.T_tile;
import game.data.bean.U_room;
import game.data.bean.U_room_hu;
import game.data.bean.U_room_level;
import game.room.RoomManage;
import game.room.ncmahjong.task.DrawTile;
import game.room.ncmahjong.task.Extractive;
import game.room.ncmahjong.task.Perflop;
import game.room.ncmahjong.task.StartGame;
import game.room.ncmahjong.task.Tick;
import ge.db.Table;

public class Room {
	public static byte[] TILE = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 24, 25, 26, 27, 28, 29, 31, 32, 33, 34, 41, 42, 43 };

	private static byte[] JS = { 8, 16, 24, 32 };
	private static byte[] RS = { 2, 3, 4 };

	public Timer timer = new Timer();
	public MJPlayer[] map;
	public byte curLevel = 1;
	public byte banker = 0;

	public final int code;

	private Table<T_tile> t_tile = new Table<T_tile>(T_tile.class, null);
	private Table<T_state> t_state = new Table<T_state>(T_state.class, null);
	private Table<U_room> u_room = new Table<U_room>(U_room.class, null, null);
	private Table<U_room_hu> u_roomhu = new Table<U_room_hu>(U_room_hu.class, null, null);
	private Table<U_room_level> u_roomlevel = new Table<U_room_level>(U_room_level.class, null, null);

	private Vector<T_tile> array;

	public U_room room;
	/**
	 * 定时器任务
	 */
	public Tick tick;
	// 发牌
	public Perflop perflop;
	public Extractive extractive;
	public DrawTile drawTile;
	public StartGame startGame;
	public byte sumLevel;
	public byte num;

	public Room(int code, int userId, byte a, byte b, byte c, byte d, byte e, byte f, byte g, byte h) {
		this.code = code;
		this.sumLevel = JS[a];
		this.num = RS[b];
		map = new MJPlayer[num];
		for (byte i = 0; i < num; i++) {
			T_state ts = new T_state(t_state, 1, i, (byte) 0, "", 0, "", (byte) 0, (byte) 0);
			map[i] = new MJPlayer(this, i, ts);
		}
		tick = new Tick(this);
		perflop = new Perflop(this);
		extractive = new Extractive(this);
		drawTile = new DrawTile(this);
		startGame = new StartGame(this);

		int time = (int) (System.currentTimeMillis() / 1000);

		room = new U_room(u_room, 0, code, userId, num, banker, (byte) -1, (byte) 0, (byte) 0, curLevel, sumLevel, (byte) 0, time);
		room.save();

		short id = 1;
		for (byte v : TILE) {
			for (int i = 0; i < 4; i++) {
				new T_tile(t_tile, id++, v, (byte) 0, (byte) 0, (byte) -1, (byte) 0);
			}
		}
	}

	public void addListener(Session session) {
		u_room.addListener(session);
		u_roomhu.addListener(session);
		u_roomlevel.addListener(session);
		t_state.addListener(session);
		t_tile.addListener(session);
	}

	public void removeListener(Session session) {
		u_room.removeListener(session);
		u_roomhu.removeListener(session);
		u_roomlevel.removeListener(session);
		t_state.removeListener(session);
		t_tile.removeListener(session);
	}

	public void saveLevel(MJPlayer p) {
		U_room_level roomlevel = new U_room_level(u_roomlevel, 0, room.id, room.curLevel, p.index, p.userId, p.sumScore, p.jing, p.jingLevel, p.baWangJing);
		roomlevel.save();
	}

	public void saveHU(MJPlayer p) {
		U_room_hu roomhu = new U_room_hu(u_roomhu, 0, room.id, room.curLevel, p.index, p.fangPao, p.tianHU, p.minSevenPairs, p.thirteenRotten, p.mevius, p.deGuo, p.maxSevenPairs, p.qiangGang, p.gangKai, p.deZhongDe, p.jingDiao);
		roomhu.save();
	}

	public T_tile getTile(int id) {
		return t_tile.get(id);
	}

	public T_tile takeTile(int id) {
		T_tile o = t_tile.get(id);
		if (o != null) {
			array.remove(o);
		} else {
			o = array.remove(0);
		}
		room.remainingTile = (short) array.size();
		room.update();
		return o;
	}

	private void shuffle() {
		array = t_tile.getList(null);
		for (T_tile o : array) {
			o.state = 0;
			o.order = (byte) (Math.random() * 127);
			o.index = -1;
			o.jing = 0;
			o.update();
		}
		array.sort(new Comparator<T_tile>() {
			public int compare(T_tile a, T_tile b) {
				return a.order - b.order;
			}
		});
	}

	public MJPlayer banker() {
		return map[banker];
	}

	public synchronized MJPlayer into(Session session) {
		for (MJPlayer p : map) {
			if (p.init(session)) {
				return p;
			}
		}
		return null;
	}

	/**
	 * 准备
	 */
	public void prepare(MJPlayer player) {
		player.state.state = 1;
		player.state.update();

		for (MJPlayer p : map) {
			if (p == null || p.state.state != 1) {
				return;
			}
		}
		startGame();
	}

	private void startGame() {
		shuffle();
		room.curLevel = curLevel;
		room.banker = banker;
		room.state = 1;
		room.update();
		for (MJPlayer p : map) {
			p.state.state = 2;
			p.state.update();
		}
		perflop.start();
	}

	/**
	 * 出牌
	 */
	public T_tile play(MJPlayer player, short id) {
		room.play = -1;
		room.update();
		tick.cancel();
		T_tile o = t_tile.get(id);
		o.state = 10;
		o.update();
		for (MJPlayer p : map) {
			if (p != player && p != null) {
				p.onPlay(o);
			}
		}
		System.out.println(o);
		return o;
	}

	/**
	 * 应牌
	 */
	public void reply() {
		MJPlayer p = null;
		boolean qiangGang = false;
		for (MJPlayer o : map) {
			if (p == null || p.pr < o.pr || p.pr == o.pr && p.dis > o.dis) {
				p = o;
			}
			if (o.pr == 5) {
				qiangGang = true;
			}
		}
		p.onReply(qiangGang);
	}

	public void exit() {
		for (MJPlayer o : map) {
			if (o.state.exit == 0) {// 有人没响应
				return;
			}
		}
		boolean agree = true;
		for (MJPlayer o : map) {
			if (o.state.exit == 2) {// 有人没同意
				agree = false;
				break;
			}
		}
		if (agree) {
			destroy();
		} else {
			for (MJPlayer o : map) {
				o.state.exit = 0;
				o.state.update();
			}
		}
	}

	public void destroy() {
		timer.cancel();
		RoomManage.it.Remove(code);
		t_tile.del();
		t_state.del();
		u_room.del();

		t_tile.clear();
		t_state.clear();
		u_room.clear();

		t_tile = null;
		t_state = null;
		u_room = null;
	}

	public void hu(MJPlayer player) {
		int sumJing = 0;
		for (MJPlayer p : map) {
			sumJing += p.baseJing();
		}
		int sumJing2 = 0;
		for (MJPlayer p : map) {
			sumJing2 += p.BaWangJing(sumJing);
		}
		for (MJPlayer p : map) {
			p.syncJing(sumJing2);
		}
		player.statistics(sumJing2);

		for (MJPlayer p : map) {
			if (p != player) {
				p.clearing(player);
			}
		}
		player.clearing();
		curLevel++;
		banker = player.index;

		room.state = 0;
		room.update();
		for (MJPlayer p : map) {
			p.state.state = 0;
			p.state.update();
		}
	}
}