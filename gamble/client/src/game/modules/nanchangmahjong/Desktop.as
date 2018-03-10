package game.modules.nanchangmahjong
{
	import game.Game;
	import game.data.bean.T_brand;
	import game.data.bean.T_state;
	import game.modules.nanchangmahjong.front.Front;
	import game.modules.nanchangmahjong.front.FrontLeft;
	import game.modules.nanchangmahjong.front.FrontOpposite;
	import game.modules.nanchangmahjong.front.FrontRight;
	import game.modules.nanchangmahjong.front.FrontSelf;
	
	import ge.gpu.display.GameObject;
	import ge.gpu.display.Image;
	import ge.net.TableEvent;

	/**
	 *桌面 
	 * @author Administrator
	 * 
	 */	
	public class Desktop extends GameObject
	{
		private var box:Image;
		private var opposite:Front;
		private var left:Front;
		private var right:Front;
		private var self:Front;
		public function Desktop(c:GameObject)
		{
			
			mouseEnabled = true;
			c.addChild(this);
			
			box=new Image(this,Game.UI_WIDTH/2,Game.UI_HEIGHT/2-50,"mahjong.100");
			box.anchor(0.5,0.5);
			
			opposite=new FrontOpposite(this);
			left=new FrontLeft(this);
			right=new FrontRight(this);
			self=new FrontSelf(this);
			
			T_brand.table.addEventListener(TableEvent.UPDATE,onBrand);
			T_state.table.addEventListener(TableEvent.UPDATE,onState);
		}
		
		private function onBrand(obj:T_brand):void
		{
			
		}
		
		private function onState(obj:T_state):void
		{
			
		}
	}
}