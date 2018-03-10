package game.room.ncmahjong.task;

import game.room.ncmahjong.Room;

public class StartGame extends Task {

	public StartGame(Room room) {
		super(room);
	}

	public void start() {
		super.start(2000);
	}

	@Override
	public void run() {
		room.room.state = 2;
		room.room.update();
		room.drawTile.start(room.banker(), false);
	}

}
