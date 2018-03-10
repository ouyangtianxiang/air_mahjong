package ge.utils{
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	
	public class Email extends Socket{
		private var my:String = "13410860916@163.com";
		private var content:String;
		private var to:String="heqifan@play91.com";
		public function Email(content:String){
			//163邮箱,你自己的帐号和密码
			super("smtp.163.com", 25);
			this.content=content;
			addEventListener(Event.CONNECT, onConnect);
			addEventListener(ProgressEvent.SOCKET_DATA , onSocketData);
			addEventListener(Event.CLOSE , onClose);
		}
		private function onConnect(evt:Event):void {
			send();
		}
		private function onSocketData(evt:ProgressEvent):void {
			var str:String=readMultiByte(bytesAvailable,"gbk");
			send();
		}
		private var index:int=0;
		private function send():void{
			switch(index++)
			{
				case 0:
					writeUTFBytes("HELO TXOY\r\n");
					flush();
					// 验证登陆
					break;
				case 1:
					writeUTFBytes("AUTH LOGIN\r\n");
					flush();
					// 用户名
					break;
				case 2:
					writeUTFBytes("MTM0MTA4NjA5MTZAMTYzLmNvbQ==\r\n");
					flush();
					// 密码
					break;
				case 3:
					writeUTFBytes("dHhveWFydA==\r\n");
					flush();
					break;
				case 4:
					writeUTFBytes("MAIL FROM: <" + my + ">\r\n");// 发件人邮箱地址,返回 250 表示成功
					flush();
					// 收件人--
					break;
				case 5:
					writeUTFBytes("RCPT TO: <" + to + ">\r\n");// 收件人地址 ,返回 250 表示成功
					flush();
					// 内容---------------
					break;
				case 6:
					writeUTFBytes("DATA\r\n");// 告诉服务器下面开始传输邮件 返回 354 表示成功
					flush();
					break;
				case 7:
					writeUTFBytes("FROM: 英雄轨迹<" + my + ">\r\n");// 回信人地址
					writeUTFBytes("TO: 何其凡<" + to + ">\r\n");// 收件人地址
					writeUTFBytes("SUBJECT: 没有的字<"+content+">\r\n");// 邮件标题
					writeUTFBytes("CONTENT-TYPE: TEXT/PLAIN;CHARSET=\"UTF-8\"\r\n");
					writeUTFBytes("\r\n");
					writeUTFBytes(content+"\r\n");// 正文数据
					writeUTFBytes("."+"\r\n");
					flush();
					break;
				case 8:
					writeUTFBytes("QUIT"+"\r\n");
					flush();
					break;
				case 9:
//					close();
					break;
			}
		}
		private function onClose(event:Event):void{
		}
	}
}