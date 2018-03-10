package game;

import java.io.IOException;

import ge.Start;

/**
 * @author txoy
 * 
 */
public class Server {
	/**
	 * @param url
	 * @param args
	 */
	private Server(String url) {
		new Start(this, url);
	}

	public static void main(String[] args) throws IOException {
		new Server("config.xml");
	}
}
