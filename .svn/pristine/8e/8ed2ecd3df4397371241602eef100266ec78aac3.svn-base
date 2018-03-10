package game.modules.nanchangmahjong.front
{
	import game.Game;
	
	import ge.gpu.display.ImageBtn;
	import game.modules.nanchangmahjong.Desktop;
	
	public class FrontSelf extends Front
	{
		public function FrontSelf(desktop:Desktop)
		{
			super(desktop);
			x=0;
			y=Game.UI_HEIGHT;
			
			new ImageBtn(this,Game.UI_WIDTH/2,-260,"ui.124");
			
			for(var i:int=0;i<13;i++){
				new Brand(this,200+i*38,-120,Brand.SELF,true,12);
			}
			for(var i:int=0;i<13;i++){
				new Brand(this,150+i*67,-50,Brand.SELF,i<4,12,true);
			}
		}
	}
}