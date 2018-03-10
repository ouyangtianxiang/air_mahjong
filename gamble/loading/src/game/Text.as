package game{
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	public class Text extends TextField{
		private var _x:int;
		private var _y:int;
		private var color:uint;
		private var size:int;
		private var anchor:Point;
		public function Text(c:DisplayObjectContainer,_x:int,_y:int,color:uint,size:int,anchor:Point){
			this._x=_x;
			this._y=_y;
			c.addChild(this);
			this.color=color;
			this.size=size;
			this.anchor=anchor;
			
			autoSize=TextFieldAutoSize.LEFT;
		}
		
		public override function set text(value:String):void{
			super.text=value;
			pos();
		}
		
		public override function set htmlText(value:String):void{
			super.htmlText=value;
			pos();
		}
		
		private function pos():void{
			setTextFormat(new TextFormat("",size,color));
			x=_x-width*anchor.x;
			y=_y-height*anchor.y;
		}
	}
}