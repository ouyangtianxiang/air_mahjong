package game.modules.login{
	import game.modules.ModuleBase;
	
	import ge.events.GameEvent;
	import ge.global.Atf;
	import ge.gpu.display.GameObject;
	import ge.gpu.display.GameText;
	import ge.gpu.display.Image;
	import ge.gpu.display.ImageBtn;
	
	public class ModuleLogin extends ModuleBase{
		private static var _it:ModuleLogin;
		
		public static function get it():ModuleLogin {
			_it = new ModuleLogin();
			return _it;
		}
		
		public function ModuleLogin(){
			super("hall_replace_scene_bg");
			var logo:Image = new Image(this, 80, 64);
			logo.load("res/other/hall_logo"+Atf);
			var btn:ImageBtn=new ImageBtn(this,800,400,"ui.100");
			btn.addEventListener(GameEvent.CLICK, onClick);
			new GameText(this,10,10,0xFFFFFF).text="南昌麻将";
		}
		
		
		public override function onAddedStage():void{
		}
		
		private function onClick(obj:GameObject):void {
			this.hide();
			
			new Login();
		}		
		
	}
}