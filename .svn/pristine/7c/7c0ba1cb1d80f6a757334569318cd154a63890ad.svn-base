package game.room;

import java.util.concurrent.ConcurrentHashMap;

import game.room.ncmahjong.Room;

public class RoomManage {
	public static final RoomManage it = new RoomManage();

	protected ConcurrentHashMap<Integer, Room> ROOMS = new ConcurrentHashMap<Integer, Room>();

	public Room Find(int roomId) {
		Room room = ROOMS.get(roomId);
		return room;
	}

	public Room CreateNCMJ(int userId, byte a, byte b, byte c, byte d, byte e, byte f, byte g, byte h) {
		int code = CreataID();
		Room room = new Room(code, userId, a, b, c, d, e, f, g, h);
		ROOMS.put(code, room);
		return room;
	}

	private synchronized int CreataID() {
		int id = 0;
		do {
			id = (int) (100000 + Math.random() * 900000);
		} while (ROOMS.containsKey(id));
		return id;
	}

	public void Remove(int code) {
		ROOMS.remove(code);
	}

}
