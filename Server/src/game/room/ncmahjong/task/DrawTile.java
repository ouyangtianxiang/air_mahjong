package game.room.ncmahjong.task;

import game.data.bean.T_tile;
import game.room.ncmahjong.MJPlayer;
import game.room.ncmahjong.Room;

public class DrawTile extends Task {

	public DrawTile(Room room) {
		super(room);
	}

	private MJPlayer player;
	private boolean gangKai;

	public void start(MJPlayer player, boolean gangKai) {
		this.player = player;
		this.gangKai = gangKai;
		if (player.vip) {
			player.userVIP((byte) 1);
		} else {
			super.start(500);
		}
	}

	@Override
	public void run() {
		drawTile(0);
	}

	public void drawTile(int id) {
		System.out.println("抓牌");
		T_tile o = room.takeTile(id);
		o.state = 1;
		o.order = 101;
		o.index = player.index;
		o.update();
		player.selfDrawn(o, gangKai);
	}
}
