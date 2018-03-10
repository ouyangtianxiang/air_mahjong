package game.application;

import game.room.RoomMahJong;
import game.utils.Protocol;
import ge.annotation.Exclude;
import ge.annotation.RemoteMethod;
import ge.net.Application;

/**
 * 南昌麻将
 */
public class NCMJ extends Application {

	public RoomMahJong room = null;
	public int userId;
	public byte index;

	protected void init() {
		userId = UserID();
	}

	@Exclude
	@RemoteMethod(Protocol.NCMJ_CREATE)
	public Object[] create(int roomId, byte diff) {
		this.index = 0;
		room = new RoomMahJong(4);
		room.into(this);
		return Result(room.roomId);
	}

	@Exclude
	@RemoteMethod(Protocol.NCMJ_INTO)
	public Object[] into(int roomId, byte index) {
		this.index = index;
		room = RoomMahJong.Find(roomId);
		room.into(this);
		return Result(room.roomId);
	}

	@Exclude
	@RemoteMethod(Protocol.NCMJ_PREPARE)
	public void prepare() {
		room.prepare(this);
	}

	@Exclude
	@RemoteMethod(Protocol.NCMJ_PLAY)
	public void play(short id) {
		room.play(this, id);
	}

	@Exclude
	@RemoteMethod(Protocol.NCMJ_REPLY)
	public void reply(short id) {
		room.reply(this, id);
	}

	@Exclude
	@RemoteMethod(Protocol.NCMJ_EXIT)
	public void exit() {
		room.exit(this);
	}

	protected void clear() {
		room.exit(this);
	}
}
