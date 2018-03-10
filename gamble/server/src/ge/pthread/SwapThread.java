package ge.pthread;

import java.lang.Thread.State;

import ge.log.Log;

/**
 * 工厂线程
 * 
 * @author Administrator
 * 
 * @param <E>
 */
public class SwapThread implements Runnable {
	public static SwapThread IT;

	public static void Init() {
		IT = new SwapThread();
	}

	private final int MAX = 0xFFFF;
	private final Runnable[] array = new Runnable[MAX + 1];
	private short begin = 0;
	private short end = 0;
	private final Object obj = new Object();
	private Thread[] threads = null;

	public boolean isRun() {
		for (Thread th : threads) {
			if (th.getState() == State.RUNNABLE) {
				return true;
			}
		}
		return false;
	}

	private SwapThread() {
		int cpu = Runtime.getRuntime().availableProcessors() * 2;
		threads = new Thread[cpu];
		for (int i = 0; i < cpu; i++) {
			threads[i] = new Thread(this, "Game-HandlerThread-" + i);
			Log.Warn(threads[i].getName());
			threads[i].start();
		}
	}

	public void run() {
		while (true) {
			Runnable run = null;
			synchronized (obj) {
				if (begin == end) {
					try {
						obj.wait();
					} catch (InterruptedException e) {
						e.printStackTrace();
					}
				}
				if (begin != end) {
					int i = MAX & begin++;
					run = array[i];
					array[i] = null;
				}
			}
			if (run != null) {
				try {
					run.run();
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

	public void push(Runnable run) {
		try {
			synchronized (obj) {
				int i = MAX & end++;
				array[i] = run;
				obj.notify();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}