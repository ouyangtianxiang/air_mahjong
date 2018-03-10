package ge.gpu.display{
	import ge.utils.tick.Tick;
	
	public class TouchScroll extends Scroll{
		/**
		 * @param c:parent
		 * @param x:x
		 * @param y:y
		 * @param w:item宽
		 * @param h:item高
		 */
		public function TouchScroll(c:GameObject,x:int,y:int,w:int,h:int,vertical:Boolean=true){
			super(c,x,y,vertical,w,h);
		}
		public function resize():void{
			Tick.nextFrame(function():void{
				size(space);
			});
		}
		private function size(sp:GameObject,x:int=0,y:int=0):void{
			for each (var go:GameObject in sp.list){
				if(go is Quad){
					var q:Quad=go as Quad;
					maxSize=Math.max(maxSize,vertical?(q.height+go.y+y):(q.width+go.x+x));
				}else{
					size(go,go.x+x,go.y+y);
				}
			}
		}
		
		//==============================================================
		public override function addChild(child:GameObject):void{
			space.addChild(child);
			resize();
		}
		
		public override function addChildAt(child:GameObject,i:uint):void{
			space.addChildAt(child,i);
			resize();
		}
		
		public override function removeChild(child:GameObject):void{
			space.removeChild(child);
			resize();
		}
		
		public override function removeChildAll():void{
			space.removeChildAll();
			resize();
		}
	}
}