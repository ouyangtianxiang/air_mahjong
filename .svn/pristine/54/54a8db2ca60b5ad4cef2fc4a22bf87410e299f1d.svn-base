package ge.gpu.display{
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import ge.events.GameEvent;
	
	public class GameClipSprite extends GameObject{
		private var _scrollRect:Rectangle;
		private var _clipRect:Rectangle=new Rectangle();
		private var _intersect:Boolean=true;
		
		public function set scrollRect(rect:Rectangle):void{
			this._scrollRect=rect;
			if(rect){
				var _x:Number=(absX+rect.x)/Game3D.it.scaleX;
				var _y:Number=(absY+rect.y)/Game3D.it.scaleY;
				var _w:Number=absScaleX*rect.width/Game3D.it.scaleX;
				var _h:Number=absScaleY*rect.height/Game3D.it.scaleY;
				if(_w<0){
					_x+=_w;
					_w=-_w;
				}
				if(_h<0){
					_y+=_h;
					_h=-_h;
				}
				if(_clipRect){
					_clipRect.setTo(_x,_y,_w,_h);
				}else{
					_clipRect=new Rectangle(_x,_y,_w,_h);
				}
				_intersect=Game3D.it.intersect(_clipRect.x,_clipRect.y,_clipRect.width,_clipRect.height);
			}
		}
		
		public function get scrollRect():Rectangle{
			return _scrollRect;
		}
		
		internal override function position():void{
			super.position();
			scrollRect=_scrollRect;
		}
		
		internal override function dispatch(event:Event):Boolean{
			if(_clipRect&&_clipRect.width/(GameEvent.StageX(event)-_clipRect.x)>=1&&_clipRect.height/(GameEvent.StageY(event)-_clipRect.y)>=1){
				return super.dispatch(event);
			}
			return false;
		}
		
		private static var rect:Rectangle;
		internal override function render(context3D:Context3D):void{
			if(_intersect && _clipRect.width>0 && _clipRect.height>0){
				var tmp:Rectangle=rect;
				if(rect){
					if(!rect.intersects(_clipRect)){
						return;
					}
					rect=rect.intersection(_clipRect);
				}else{
					rect=_clipRect;
				}
				context3D.setScissorRectangle(rect);
				super.render(context3D);
				rect=tmp;
				context3D.setScissorRectangle(rect);
			}
		}
	}
}