package ge.gpu.display{
	import ge.gpu.texture.FontTexture;
	
	public class Char extends Quad{
		private var _stroke:Boolean;
		public function Char(c:GameObject){
			c.addChild(this);
		}
		
		public function init(char:String,color:uint,size:uint,stroke:Boolean,bold:Boolean,gray:Boolean):void{
			scale=size/30;
			texture=FontTexture.Font(char);
			_stroke=stroke;
			_gray=gray;
			setColor(color);
		}
		
		public function pos(x:int,y:int):void{
			this.x=x;
			this.y=y;
		}
		
		public override function remove():void{
			super.remove();
			texture=null;
		}
	}
}