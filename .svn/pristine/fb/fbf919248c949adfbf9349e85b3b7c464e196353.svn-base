package ge.utils;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.Socket;

import ge.Config;
import ge.log.Log;
import ge.pthread.Tick;
import sun.misc.BASE64Encoder;

public class Email extends Tick {
	private PrintWriter output = null;
	private BufferedReader input = null;
	private Socket socket = null;
	private String my = "13410860916@163.com";
	private String to = "13410860916@139.com";
	private String content;
	private String subject;

	public Email(String subject, String content) {
		super(1000, 1);
		this.subject = subject;
		this.content = content;
	}

	public void run() {
		try {
			socket = new Socket("smtp.163.com", 25);
			output = new PrintWriter(new OutputStreamWriter(socket.getOutputStream()));
			input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
			output.println("HELO TXOY");
			output.flush();
			input.readLine();
			// 验证登陆
			output.println("AUTH LOGIN");
			output.flush();
			input.readLine();
			// 用户名
			output.println(new BASE64Encoder().encode(my.getBytes()));
			output.flush();
			input.readLine();
			// 密码
			String password = "txoyart";
			output.println(new BASE64Encoder().encode(password.getBytes()));
			output.flush();
			input.readLine();

			String addresser = socket.getLocalAddress().toString();

			// 发件人--
			output.println("MAIL FROM: <" + my + ">");// 发件人邮箱地址,返回 250 表示成功
			output.flush();
			input.readLine();
			// 收件人--
			output.println("RCPT TO: <" + to + ">");// 收件人地址 ,返回 250 表示成功
			output.flush();
			input.readLine();
			// 内容---------------
			output.println("DATA");// 告诉服务器下面开始传输邮件 返回 354 表示成功
			output.flush();
			input.readLine();
			output.println("FROM: <" + my + ">");// 回信人地址
			output.println("TO: <" + to + ">");// 收件人地址
			output.println("SUBJECT: " + subject);// 邮件标题
			output.println("CONTENT-TYPE: TEXT/PLAIN;CHARSET=\"UTF-8\"");
			output.println();
			output.println(content);// 正文数据
			output.println(addresser + ":" + Config.get("ServerPort"));// 正文数据
			output.println(".");
			output.flush();
			input.readLine();

			output.println("QUIT");
			input.readLine();

			socket.close();
			input.close();
			output.close();
			Log.Info("...");
		} catch (Exception e) {
			Log.Info("SendEmail Failure");
		}
	}
}