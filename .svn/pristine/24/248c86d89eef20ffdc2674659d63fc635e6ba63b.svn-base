package ge.gpu.display{
	import ge.gpu.texture.UITexture;
	
	
	public class GameGrid3 extends GameGrid{
		public function GameGrid3(container:GameObject,x:int,y:int,img:String,size:int,isLandscape:Boolean=true){
			this.x = x;
			this.y = y;
			container.addChild(this);
			var array:Array;
			if(isLandscape){
				array =UITexture.UI(img,3,1);
				var w:Number=array[0].width;
				quad(0,0,array[0]);
				quad(w,0,array[1],(size-w*2)/w);
				quad(size-w,0,array[2]);
			}else{
				array =UITexture.UI(img,1,3);
				var h:Number=array[0].height;
				quad(0,0,array[0]);
				quad(0,h,array[1],1,(size-h*2)/h);
				quad(0,size-h,array[2]);
			}
		}
	}
}