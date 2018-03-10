package ge;

import java.util.LinkedList;

public abstract class Stop {
	private static LinkedList<Stop> list = new LinkedList<Stop>();

	public synchronized static void stop() {
		for (Stop s : list) {
			s.onStop();
		}
		list.clear();
	}

	public Stop() {
		list.add(this);
	}

	public abstract void onStop();

	public final void cancel() {
		list.remove(this);
	}
}
