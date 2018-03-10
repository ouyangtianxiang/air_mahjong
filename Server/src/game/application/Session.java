package game.application;

import game.data.Data;
import game.room.RoomManage;
import game.room.ncmahjong.MJPlayer;
import game.room.ncmahjong.Room;
import game.utils.Protocol;
import ge.annotation.RemoteMethod;
import ge.net.Handler;

public class Session extends Handler {
	public Data data;

	/**
	 * 登录游戏
	 */
	@RemoteMethod(Protocol.LOGIN)
	public Object[] login(String accessToken, int channe, String passId, short areaId) {
		System.out.println("login:" + accessToken + " " + channe + " " + passId + " " + areaId);
		// call(Protocol.LOGIN, 1234);
		if (data == null) {
			data = new Data(this);
		}
		data.login(passId, "");

		return Result(data.UserID);
	}

	/**
	 * 请求用户数据
	 */
	@RemoteMethod(Protocol.LOGIN_USER_DATA)
	public Object[] userData() {
		System.out.println("user:" + client);
		data.load();
		return Result((byte) 0);
	}

	public MJPlayer mjPlayer;

	@RemoteMethod(Protocol.NCMJ_CREATE)
	public Object[] createRoom(byte a, byte b, byte c, byte d, byte e, byte f, byte g, byte h) {
		Room room = RoomManage.it.CreateNCMJ(data.UserID, a, b, c, d, e, f, g, h);
		mjPlayer = room.into(this);
		return Result(mjPlayer.index, room.code);
	}

	@RemoteMethod(Protocol.NCMJ_INTO)
	public Object[] intoRoom(int roomId) {
		Room room = RoomManage.it.Find(roomId);
		if (room != null) {
			mjPlayer = room.into(this);
			if (mjPlayer != null) {
				return Result(mjPlayer.index, room.code);
			}
			return Result((byte) -1);
		}
		return Result((byte) -2);
	}

	@RemoteMethod(Protocol.NCMJ_USER_VIP)
	public void CardDrafting(short id) {
		mjPlayer.CardDrafting(id);
	}

	@RemoteMethod(Protocol.NCMJ_PREPARE)
	public Object[] prepare() {
		mjPlayer.prepare();
		return Result(0);
	}

	// 出牌
	@RemoteMethod(Protocol.NCMJ_PLAY)
	public void play(short id) {
		mjPlayer.play(id);
	}

	// type:0:过,1:吃,2:碰,4:杠,8:胡
	@RemoteMethod(Protocol.NCMJ_REPLY)
	public Object[] reply(boolean selfmo, short id) {
		mjPlayer.reply(selfmo, id);
		return Result(0);
	}

	@RemoteMethod(Protocol.NCMJ_EXIT)
	public void exit(byte type) {
		mjPlayer.exit(type);
	}

	protected void clear() {
		if (data != null) {
			data.clear();
			data = null;
		}
		if (mjPlayer != null) {
			mjPlayer.clear();
		}
	}
}
