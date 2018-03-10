package game.modules.nanchangmahjong
{
	import game.modules.window.WinModal;
	import game.utils.Protocol;
	
	import ge.events.GameEvent;
	import ge.gpu.display.ButtonExt;
	import ge.gpu.display.GameGrid9;
	import ge.gpu.display.GameObject;
	import ge.gpu.display.GameText;
	import ge.gpu.display.Image;
	import ge.gpu.display.ImageBtn;
	import ge.net.Buffer;
	import ge.net.IM;
	import ge.net.type.byte;
	
	public class IntoRoom extends WinModal
	{
		private static var _it:IntoRoom;
		
		public static function get it():IntoRoom {
			if(_it==null){
				_it = new IntoRoom();
			}
			return _it;
		}
		private var arr:Vector.<GameText>=new Vector.<GameText>(6);
		private var data:Array=["1","2","3","4","5","6","7","8","9","重输","0","删除"];
		public function IntoRoom()
		{
			super(600,600);
			new GameGrid9(this, 0, 0, "ui.201", width, height, false).mouseEnabled = false;
			new Image(this, width  / 2, 0,"ui.202").anchor(0.5,0);
			
			for(var j:int=0;j<6;j++){
				var bg:Image=new Image(this,j*90+40,80,"ui.136");
				arr[j]=new GameText(bg,26,20,0xFFFFFF);
			}
			
			var txt:GameText=new GameText(this,300,170,0xFFFFFF);
			txt.anchor(0.5,0.5);
			txt.text="请输入房间号";
			
			for(var i:int=0;i<12;i++){
				var btn:ButtonExt=new ButtonExt(this,i%3*155+140,int(i/3)*90+250,"ui.130",data[i],0xFFFFFF);
				btn.name=i;
				btn.addEventListener(GameEvent.CLICK,onClick);
			}
			
			var btn1:ImageBtn=new ImageBtn(this,570,30,"ui.134");
			btn1.addEventListener(GameEvent.CLICK, onClick1);
		}
		
		private function onClick(obj:GameObject):void
		{
			if(obj.name==9){
				value="";
				fill();
			}else if(obj.name==11){
				value=value.substr(0,-1);
				fill();
			}else{
				if(value.length<6){
					value+=data[obj.name];
					fill();
				}
			}
		}
		
		public var value:String="";
		
		private function fill():void{
			for(var i:int=0;i<arr.length;i++){
				arr[i].text=value.charAt(i);
			}
			if(value.length==6){
				trace(value);
				var roomId:int=int(value);
				IM.Call(Protocol.NCMJ_INTO,onIntoRoom,roomId,new byte(0));
			}
		}
		
		private function onIntoRoom(buffer:Buffer):void
		{
			this.hide();
			var roomID:int=buffer.readInt();
			ModuleNanchangMahjong.it.init(roomID);
		}
		
		public override function hide():void {
			super.hide();
			value="";
			fill();
		}
		
		private function onClick1(obj:GameObject):void
		{
			this.hide();
		}
	}
}