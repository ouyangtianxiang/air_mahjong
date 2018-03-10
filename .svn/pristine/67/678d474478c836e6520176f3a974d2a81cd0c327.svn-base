package game {
	import game.modules.login.ModuleLogin;
	
	import ge.global.GM;
	import ge.gpu.display.GameObject;
	import ge.gpu.display.GameSington;
	import ge.gpu.texture.UITexture;
	
	public class Game extends GameObject {
		public static var it : Game;
		public static const W : int = 1134;
		public static const H : int = 640;
		public static var UI_WIDTH : Number;
		public static var UI_HEIGHT : Number;
		public var tip : GameObject;
		public var modal : GameObject;
		public var sington : GameSington;
		
		public function Game() {
			it = this;
			mouseEnabled = true;
			
			scale = Math.min(GM.GameWidth / W, GM.GameHeight / H);
			UI_WIDTH = GM.GameWidth/scaleX;
			UI_HEIGHT = GM.GameHeight/scaleY;
			
			sington = new GameSington(this);
			modal = new GameObject();
			modal.mouseEnabled = true;
			addChild(modal);
			tip = new GameObject();
			addChild(tip);
			
			UITexture.Load("res/ui/", "ui",onStart);
		}
		
		public function onStart() : void {
			
			ModuleLogin.it.show();
		}
		
		public function init() : void {
			sington.dispose();
		}
		
		public static function Dispose():void{
			if(it){
				if(it.sington){
					it.sington.dispose();
				}
			}
		}
	}
}