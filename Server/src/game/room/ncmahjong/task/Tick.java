package game.room.ncmahjong.task;

import game.room.ncmahjong.Room;

public class Tick extends Task {

	private byte time;
	private byte index;

	public Tick(Room room) {
		super(room);
	}

	public void start(byte index) {
		this.time = 30;
		this.index = index;
		super.start(100, 1000);
	}

	@Override
	public void run() {
		room.room.play = index;
		room.room.time = time--;
		room.room.update();
		if (time < 0) {
			cancel();
		}
	}
}