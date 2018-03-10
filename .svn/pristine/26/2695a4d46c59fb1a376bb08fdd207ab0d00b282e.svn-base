package ge.gpu.display{
	import ge.gpu.texture.UITexture;
	
	
	public class GameGrid9 extends GameGrid{
		public function GameGrid9(container:GameObject,x:int,y:int,img:String,width:int,height:int,hollow:Boolean=true,top:Boolean=true,down:Boolean=true,left:Boolean=true,right:Boolean=true){
			this.x = x;
			this.y = y;
			container.addChild(this);
			var array:Array =UITexture.UI(img,3,3);
			var w:Number=array[0].width;
			var h:Number=array[0].height;
			
			var w1:Number=left?w:0;
			var h1:Number=top?h:0;
			var w3:Number=right?w:0;
			var h3:Number=down?h:0;
			var w2:Number=width-w1-w3;
			var h2:Number=height-h1-h3;
			
			var sw:Number=w2/w;
			var sh:Number=h2/h;
			
			if(top){
				if(left)quad(0,0,array[0]);
				quad(w1,0,array[1],sw);
				if(right)quad(w1+w2,0,array[2]);
			}
			
			if(left)quad(0,h1,array[3],1,sh);
			if(!hollow)quad(w1,h1,array[4],sw,sh);
			if(right)quad(w1+w2,h1,array[5],1,sh);
			
			if(down){
				if(left)quad(0,h1+h2,array[6]);
				quad(w1,h1+h2,array[7],sw);
				if(right)quad(w1+w2,h1+h2,array[8]);
			}
		}
	}
}