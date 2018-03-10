package ge.gpu.display{

	public class ButtonExt extends ImageBtn{
		private var txt:GameText;
		public function ButtonExt(c:GameObject,x:int,y:int,img:String,text:String,color : uint, size : uint = GameText.SIZE_S){
			super(c,x,y,img);

			txt=new GameText(this,0,0,color,size,true,true);
			txt.anchor(0.5,0.5);
			txt.text=text;
		}
		
		public function title(text : String) : void {
			txt.text=text;
		}
		
		public override function set click(value:Boolean):void{
			super.click = value;
			txt.gray=!value;
		}
	}
}