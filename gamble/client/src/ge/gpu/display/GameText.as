package ge.gpu.display{
	import ge.gpu.utils.HtmlText;
	
	public class GameText extends GameObject{
		public static const SIZE_S:int=24;
		public static const SIZE_M:int=32;
		public static const SIZE_L:int=48;
		
		private var i:uint;
		private var px:int;
		private var py:int;
		private var _color:uint;
		private var _size:uint;
		private var _bold:Boolean;
		private var _stroke:Boolean;
		private var maxWidth:uint;
		private var _width:Number=0;
		private var _height:Number=0;
		private var r:int;
		private var rowheight:int;
		public function GameText(c:GameObject,x:int,y:int,color : uint = 0xFFFFFF, size : uint = SIZE_S,stroke : Boolean = false, bold : Boolean = false,maxWidth:uint=0){
			this.x=x;
			this.y=y;
			c.addChild(this);
			this._color=color;
			this._size=size;
			this._stroke=stroke;
			this._bold=bold;
			this.maxWidth=maxWidth;
		}
		
		public function set color(value : uint) : void {
			this._color=value;
			for each (var o:GameObject in list){
				o.setColor(value);
			}
		}
		
		public function newline():void{
			px=0;
			r=0;
			py+=rowheight;
		}
		
		private function addChar(char:String,color:uint,size:uint,stroke : Boolean, bold : Boolean):void{
			var code:int=char.charCodeAt();
			if(code==10||code==13){
				newline();
				return;
			}
			var _char:Char=list.length>i?list[i]:new Char(this);
			_char.mouseEnabled=mouseEnabled;
			_char.init(char,color,size,stroke,bold,_gray);
			if(maxWidth>0&&px+_char.width>maxWidth){
				newline();
			}
			_char.pos(px,py);
			_width=Math.max(_width,px+_char.width);
			_height=Math.max(_height,py+_char.height);
			px+=_char.width;
			
			rowheight=r==0?_char.height:Math.max(rowheight,_char.height);
			
			i++;
			r++;
		}
		
		
		public override function get absX() : Number {
			return super.absX-absScaleX*_anchorX;
		}
		
		public override function get absY() : Number {
			return super.absY-absScaleY*_anchorY;
		}
		private var _anchorX:Number=0;
		private var _anchorY:Number=0;
		private var ax:Number=0;
		private var ay:Number=0;
		public function anchor(ax:Number,ay:Number):void{
			this.ax=ax;
			this.ay=ay;
			_anchorX=_width*ax;
			_anchorY=_height*ay;
		}		
		
		public function get width():int{
			return _width;
		}
		
		public function get height():int{
			return _height;
		}
		
		private function init():void{
			_width=_height=i=r=px=py=0;
		}
		
		public function clear():void{
			init();
			clean();
		}
		
		private function clean():void{
			while(list.length>i){
				list[i].remove();
			}
			anchor(ax,ay);
		}
		
		public function append(str:String,color : Object = null, size : Object = null,stroke : Object = null, bold : Object = null):void{
			_append(str,color!=null?color as uint:_color,size!=null?size as uint:_size,stroke!=null?stroke :_stroke,bold!=null?bold :_bold);
		}
		
		public function appends(...arg:*) : void {
			var html:HtmlText=new HtmlText(null,_color);
			html.appends.apply(html,arg);
			htmlText=html;
		}
		
		private function _append(str:String,color : uint, size : uint,stroke : Boolean, bold : Boolean):void{
			for(var i:int=0;i<str.length;i++){
				addChar(str.charAt(i),color,size,stroke,bold);
			}
		}
		
		public function set text(str:String):void{
			init();
			if(str){
				append(str,_color,_size,_stroke,_bold);
			}
			clean();
		}
		
		public function set htmlText(html:HtmlText):void{
			init();
			if(html){
				while(html.length>0){
					append(html.shift(),html.shift(),html.shift(),html.shift(),html.shift());
				}
			}
			clean();
		}
	}
}