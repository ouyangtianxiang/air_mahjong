package game.modules.nanchangmahjong.front
{
	import game.Game;
	
	import ge.gpu.display.ImageBtn;
	import game.modules.nanchangmahjong.Desktop;
	
	public class FrontLeft extends Front
	{
		public function FrontLeft(desktop:Desktop)
		{
			super(desktop);
			x=0;
			y=0;
			
			new ImageBtn(this,Game.UI_WIDTH/2,-260,"ui.124");
			
			for(var i:int=0;i<13;i++){
				new Brand(this,200,150+i*30,Brand.LEFT,true,6);
			}
			
			
			for(var i:int=0;i<13;i++){
				new Brand(this,150,80+i*30,Brand.LEFT,i<4,12);
			}
		}
	}
}