package ge.gpu.display{
	import ge.gpu.texture.BaseTexture;

	public class GameGrid extends GameObject{
		protected function quad(x:Number,y:Number,texture:BaseTexture,scaleX:Number=1,scaleY:Number=1):void{
			var q:Quad=new Quad();
			q.x=x;
			q.y=y;
			q.texture=texture;
			q.scaleX=scaleX;
			q.scaleY=scaleY;
			addChild(q);
		}
		
		public override function set mouseEnabled(value:Boolean):void{
			super.mouseEnabled=value;
			for each (var o:GameObject in list){
				o.mouseEnabled=value;	
			}
		}
	}
}