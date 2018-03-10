package game.modules.nanchangmahjong.front
{
	import ge.gpu.display.GameObject;
	import game.modules.nanchangmahjong.Desktop;

	/**
	 *方位基类 
	 * @author Administrator
	 * 
	 */	
	public class Front extends GameObject
	{
		public function Front(desktop:Desktop)
		{
			mouseEnabled = true;
			desktop.addChild(this);
		}
		
		private function sort():void {
			var len:int = list.length;
			for (var l:int = len - 1; l > 0; l--) {
				for (var i:int = 0; i < l; i++) {
					var a:GameObject = list[l];
					var b:GameObject = list[i];
					if (a.y < b.y) {
						list[i] = a;
						list[l] = b;
					}
				}
			}
		}
	}
}