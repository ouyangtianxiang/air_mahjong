package ge.utils;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.HttpURLConnection;
import java.net.URL;

public class Http {
	public static final String CHARSET = "UTF-8";
	private String data = null;

	private String url;
	private String param;

	public Http(String url) {
		this(url, null);
	}

	public Http(String url, String param) {
		this.url = url;
		this.param = param;
		send();
	}

	protected HttpURLConnection createConnection(URL url) throws Exception {
		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		return conn;
	}

	protected BufferedReader inputBuffer(InputStream is) throws Exception {
		return new BufferedReader(new InputStreamReader(is, CHARSET));
	}

	public void send() {
		PrintWriter out = null;
		BufferedReader in = null;
		try {
			HttpURLConnection conn = createConnection(new URL(url));
			conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
			conn.setDoOutput(true);
			conn.setDoInput(true);

			out = new PrintWriter(conn.getOutputStream());
			System.out.println("param：" + param);
			if (param != null) {
				out.print(new String(param.getBytes(), CHARSET));
			}
			out.flush();
			out.close();

			InputStream is = null;
			try {
				is = conn.getInputStream();
			} catch (IOException e) {
				is = conn.getErrorStream();
			} finally {
				in = inputBuffer(is);
				data = "";
				String line;
				while ((line = in.readLine()) != null) {
					data += line;
				}
				in.close();
				is.close();
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public String getData() {
		return data;
	}
}
