package ge.pthread;

import java.util.LinkedList;

import ge.log.Log;

public class TickThread extends Thread {
	public static TickThread IT;

	public static void Init() {
		IT = new TickThread();
	}

	private static LinkedList<Tick> ticks = new LinkedList<Tick>();

	private TickThread() {
		super("Game-TickThread");
		Log.Warn(getName());
		start();
	}

	void push(Tick tick) {
		tick.runTime = System.currentTimeMillis() + tick.delay;
		synchronized (obj) {
			ticks.remove(tick);
			int len = ticks.size();
			for (int i = 0; i < len; i++) {
				if (ticks.get(i).runTime > tick.runTime) {
					ticks.add(i, tick);
					obj.notify();
					return;
				}
			}
			ticks.add(tick);
			obj.notify();
		}
	}

	boolean contains(Tick tick) {
		synchronized (obj) {
			return ticks.contains(tick);
		}
	}

	void remove(Tick tick) {
		synchronized (obj) {
			ticks.remove(tick);
		}
	}

	private Object obj = new Object();

	public void run() {
		while (true) {
			Tick tick = null;
			synchronized (obj) {
				Tick t = ticks.peek();
				if (t != null) {
					long time = System.currentTimeMillis();
					if (t.runTime <= time) {
						tick = ticks.poll();
					} else {
						try {
							obj.wait(t.runTime - time);
						} catch (InterruptedException e) {
							e.printStackTrace();
						}
					}
				} else {
					try {
						obj.wait();
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
			}
			if (tick != null) {
				try {
					tick.onTick();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}
}