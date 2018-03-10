package game.room;

import game.application.NCMJ;
import ge.net.Buffer;
import ge.net.Call;

public abstract class RoomBase extends Call {
	protected NCMJ[] map;

	public final int roomId;

	public RoomBase(int roomId, int size) {
		this.roomId = roomId;
		map = new NCMJ[size];
	}

	public void into(NCMJ room) {
		map[room.index] = room;
	}

	public void Send(Buffer buffer) {
		for (NCMJ room : map) {
			buffer.rewind();
			room.Send(buffer);
		}
	}

	public synchronized void remove(NCMJ room) {
		map[room.index] = null;
	}
}
