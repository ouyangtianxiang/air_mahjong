package game.modules.hall{
	import game.data.bean.U_data;
	import game.modules.ModuleBase;
	import game.modules.nanchangmahjong.CreateRoom;
	import game.modules.nanchangmahjong.IntoRoom;
	import game.utils.Music;
	
	import ge.events.GameEvent;
	import ge.global.Atf;
	import ge.gpu.display.GameGrid3;
	import ge.gpu.display.GameNumber;
	import ge.gpu.display.GameObject;
	import ge.gpu.display.Image;
	import ge.gpu.display.ImageBtn;
	import ge.gpu.texture.UITexture;
	
	public class ModuleHall extends ModuleBase{
		private static var _it:ModuleHall;
		
		public static function get it():ModuleHall {
			if(_it==null){
				_it = new ModuleHall();
			}
			return _it;
		}
		
		public function ModuleHall(){
			super("hall");
			
			var logo:Image = new Image(this, 200, 80);
			logo.load("res/other/nvhai"+Atf);
			
			UITexture.Load("res/slice/", "slice",onStart);
		}
		
		public function onStart() : void {
			new GameGrid3(this, 300, 0,"ui.103",536);
			new Image(this,width/2,20,"ui.302").anchor(0.5,0);
			
			
			
			var btn1:ImageBtn=new ImageBtn(this,835,200,"ui.104");
			var btn2:ImageBtn=new ImageBtn(this,800,400,"ui.106");
			btn1.addEventListener(GameEvent.CLICK, onClick1);
			btn2.addEventListener(GameEvent.CLICK, onClick2);
			
			var bottom:GameGrid3 = new GameGrid3(this, 0, height-100,"ui.102",width);
			new GameGrid3(this, 150, height-60,"ui.114",150);
			new GameNumber(this,150,height-60,"slice.110",1234567890);
			
			new GameGrid3(this, 450, height-60,"ui.114",150);
			new GameNumber(this,450,height-60,"slice.131",12,0,1);
			
			new Image(this,20,height-130,"ui.108");
			new Image(this,350,height-80,"ui.109");
			
			new ImageBtn(this,640,height-40,"ui.110");
			new ImageBtn(this,760,height-40,"ui.111");
			new ImageBtn(this,880,height-40,"ui.112");
			new ImageBtn(this,1000,height-40,"ui.113");
			
			U_data.table;
		}
		
		private function onClick1(obj:GameObject):void
		{
			IntoRoom.it.show();
		}
		
		private function onClick2(obj:GameObject):void
		{
			CreateRoom.it.show();
		}
		
		public override function onAddedStage():void{
			super.onAddedStage();
			Music.it.BGMusic(1);
		}
		
	}
}