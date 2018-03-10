package game.modules.nanchangmahjong{
	import flash.events.DataEvent;
	
	import game.Game;
	import game.data.bean.T_state;
	import game.data.bean.U_data;
	import game.modules.ModuleBase;
	import game.utils.Music;
	import game.utils.Protocol;
	
	import ge.events.GameEvent;
	import ge.gpu.display.GameNumber;
	import ge.gpu.display.GameObject;
	import ge.gpu.display.ImageBtn;
	import ge.gpu.texture.UITexture;
	import ge.net.IM;
	import ge.net.TableEvent;
	
	public class ModuleNanchangMahjong extends ModuleBase{
		private static var _it:ModuleNanchangMahjong;
		private var roomID:GameNumber;
		
		public static function get it():ModuleNanchangMahjong {
			if(_it==null){
				_it = new ModuleNanchangMahjong();
			}
			return _it;
		}
		
		public function ModuleNanchangMahjong(){
			super("zhuomian");
			roomID=new GameNumber(this,200,20,"slice.122",2345,0);
			var btn1:ImageBtn=new ImageBtn(this,80,40,"ui.120");
			//btn1.img="ui.121";
			btn1.addEventListener(GameEvent.CLICK, onClick1);
			
			var btn3:ImageBtn=new ImageBtn(this,Game.UI_WIDTH/2,Game.UI_HEIGHT/2-50,"ui.123");
			btn3.addEventListener(GameEvent.CLICK, onClick3);	
			
			UITexture.Load("res/mahjong/", "mahjong",onStart);
			
			T_state.table.addEventListener(TableEvent.DELETE,onT_stateDelete);
		}		
		
		private function onT_stateDelete(event:TableEvent):void
		{
			var o:U_data=U_data.table.getObj();
			if(T_state(event.obj).userId==o.userId){	
				hide();
			}
		}
		
		public override function onAddedStage():void{
			super.onAddedStage();
			Music.it.BGMusic(1);
		}
		
		public function onStart() : void {
			new Desktop(this);
		}
		
		
		public function init(roomId:int):void{
			roomID.value=roomId;
			show();
		}
		
		private function onClick1(obj:GameObject):void
		{
			IM.Call(Protocol.NCMJ_EXIT,null);
		}
		
		private function onClick3(obj:GameObject):void
		{
			
		}
	}
}