package game.modules.nanchangmahjong.front
{
	import game.Game;
	
	import ge.gpu.display.ImageBtn;
	import game.modules.nanchangmahjong.Desktop;
	
	public class FrontOpposite extends Front
	{
		public function FrontOpposite(desktop:Desktop)
		{
			super(desktop);
			x=Game.UI_WIDTH;
			y=0;
			
			new ImageBtn(this,Game.UI_WIDTH/2,-260,"ui.124");
			
			for(var i:int=0;i<13;i++){
				new Brand(this,i*-39-300,50,Brand.OPPOSITE,i<4,9);
			}
			for(var i:int=0;i<13;i++){
				new Brand(this,i*-38-400,120,Brand.OPPOSITE,true,8);
			}
		}
	}
}