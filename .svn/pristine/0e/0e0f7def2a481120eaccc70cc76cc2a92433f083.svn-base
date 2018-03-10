package ge.pthread;

/**
 * 计时器基类
 * 
 * @author Administrator
 * 
 */
public abstract class Tick implements Runnable {
	int delay;
	private int repeat;
	long runTime;

	/**
	 * 创建计时器
	 */
	public Tick() {
	}

	/**
	 * 创建计时器
	 * 
	 * @param delay
	 *            延时时间(毫秒)
	 * @param repeat
	 *            重复次数(0为无限次)
	 */
	public Tick(int delay, int repeat) {
		start(delay, repeat);
	}

	/**
	 * 启动计时器
	 * 
	 * @param delay
	 *            延时时间(毫秒)
	 * @param repeat
	 *            重复次数(0为无限次)
	 */
	public final void start(int delay, int repeat) {
		this.delay = delay;
		this.repeat = repeat;
		start();
	}

	public final void onTick() {
		SwapThread.IT.push(this);
		if (repeat != 1) {
			start();
		}
		if (repeat > 1) {
			repeat--;
		}
	}

	private final void start() {
		TickThread.IT.push(this);
	}

	/**
	 * 取消计时
	 */
	public final void cancel() {
		repeat = 1;
		TickThread.IT.remove(this);
	}

	/**
	 * @return 是否已经启动
	 */
	public final boolean isStart() {
		return TickThread.IT.contains(this);
	}
}
