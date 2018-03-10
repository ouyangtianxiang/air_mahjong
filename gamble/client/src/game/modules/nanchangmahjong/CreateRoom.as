package game.modules.nanchangmahjong {
	import game.modules.window.WinModal;
	import game.utils.Protocol;
	
	import ge.events.GameEvent;
	import ge.gpu.display.ButtonExt;
	import ge.gpu.display.CheckBox;
	import ge.gpu.display.GameGrid9;
	import ge.gpu.display.GameObject;
	import ge.gpu.display.GameText;
	import ge.gpu.display.Image;
	import ge.gpu.display.TouchScroll;
	import ge.net.Buffer;
	import ge.net.IM;
	import ge.net.type.byte;
	
	public class CreateRoom extends WinModal {
		private static var _it:CreateRoom;
		
		public static function get it():CreateRoom {
			if(_it==null){
				_it = new CreateRoom();
			}
			return _it;
		}
		
		private var scroll:TouchScroll;
		
		[Embed(source="room.xml", mimeType="application/octet-stream")] 
		protected const EmbeddedXML:Class;
		private var data:XML=XML(new EmbeddedXML);
		private var array:Array=[];
		public function CreateRoom() {
			super(660,620);
			new GameGrid9(this, 0, 0, "ui.201", width, height, false).mouseEnabled = false;
			new Image(this, width  / 2, 0,"ui.200").anchor(0.5,0);
			
			new GameGrid9(this, 26,55, "ui.203", 610,460, false);
			scroll=new TouchScroll(this,28,57,606,456);
			
			var _y:int=0;
			
			var xmllist:XMLList=data.children();
			for each (var item:XML in xmllist) 
			{
				_y+=10;
				new GameText(scroll,20,_y,0xFFFF00).text=item.@name;
				_y+=35;
				var xmllist2:XMLList=item.children();
				
				var len:int=xmllist2.length();
				var h:int=Math.ceil(len/2)*50+10;
				
				new GameGrid9(scroll, 10,_y, "ui.203", 588,h, false);
				var g:Object={};
				for(var i:int=0;i<len;i++){
					var d:XML=xmllist2[i];
					
					var cb:CheckBox=new CheckBox(scroll,i%2*300+40,int(i/2)*50+_y+30,"ui.301","ui.300",d.@name,0xFF00FF,g,d.@id==1);
					cb.name=d.@id;
				}
				_y+=h;
				array.push(g);
			}
			
			var btn1:ButtonExt=new ButtonExt(this,130,565,"ui.131","取消",0xAAAAAA);
			var btn2:ButtonExt=new ButtonExt(this,530,565,"ui.132","创建",0xAAAAAA);
			
			btn1.addEventListener(GameEvent.CLICK, onClick1);
			btn2.addEventListener(GameEvent.CLICK, onClick2);
		}
		
		private function onClick2(obj:GameObject):void
		{
			for(var i:int=0;i<array.length;i++){
				trace(array[i].obj.name);
			}
			IM.Call(Protocol.NCMJ_CREATE,onCreateRoom,1,new byte(0));
		}
		
		private function onCreateRoom(buffer:Buffer):void
		{
			this.hide();
			var roomID:int=buffer.readInt();
			ModuleNanchangMahjong.it.init(roomID);
		}
		
		private function onClick1(obj:GameObject):void
		{
			this.hide();
		}
	}
}
