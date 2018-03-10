package game.modules.nanchangmahjong.front
{
	import game.Game;
	
	import ge.gpu.display.ImageBtn;
	import game.modules.nanchangmahjong.Desktop;
	
	public class FrontRight extends Front
	{
		public function FrontRight(desktop:Desktop)
		{
			super(desktop);
			x=Game.UI_WIDTH;
			y=0;
			
			new ImageBtn(this,Game.UI_WIDTH/2,-260,"ui.124");
			
			for(var i:int=0;i<13;i++){
				new Brand(this,-200,150+i*30,Brand.RIGHT,true,5);
			}
			
			for(var i:int=0;i<13;i++){
				new Brand(this,-150,80+i*30,Brand.RIGHT,i<4,12);
			}
		}
	}
}