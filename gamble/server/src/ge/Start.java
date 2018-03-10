package ge;

import ge.log.Log;
import ge.net.Client;
import ge.net.Handler;
import ge.pthread.AcceptThread;
import ge.pthread.IOThread;
import ge.pthread.SwapThread;
import ge.pthread.TickThread;

import java.util.Iterator;
import java.util.Map.Entry;

import sun.misc.Signal;
import sun.misc.SignalHandler;

public class Start {

	public Start(Object obj, String url) {
		Config.Init(url);
		Log.Init();
		TickThread.Init();
		IOThread.Init();
		SwapThread.Init();
		Handler.init(obj);
		AcceptThread.Start();

		Hook hook = new Hook();
		Signal.handle(new Signal("TERM"), hook);/* 注册KILL信号 */
		Signal.handle(new Signal("INT"), hook);/* 注册CTRL+C信号 */
	}

	static class Hook implements SignalHandler {
		public void handle(Signal signal) {
			System.out.println("Signal:" + signal.getName() + "(" + signal.getNumber() + ")");
			AcceptThread.Stop();
			Stop.stop();
			Iterator<Entry<Integer, Client>> it = Client.clients.entrySet().iterator();
			while (it.hasNext()) {
				it.next().getValue().close();
			}
			try {
				Thread.sleep(1000);
				while (SwapThread.IT.isRun()) {
					Thread.sleep(1000);
				}
				for (int i = 10; i >= 0; i--) {
					System.out.println("..." + i);
					Thread.sleep(1000);
				}
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
			System.out.println("...Exit");
			System.exit(0);
		}
	}
}
