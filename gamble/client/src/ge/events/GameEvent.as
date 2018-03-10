package ge.events{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	
	import ge.gpu.display.Game3D;

	public class GameEvent extends Event{
		public static const CLICK:String=Multitouch.supportsTouchEvents?TouchEvent.TOUCH_TAP:MouseEvent.CLICK;
		public static const DOWN:String=Multitouch.supportsTouchEvents?TouchEvent.TOUCH_BEGIN:MouseEvent.MOUSE_DOWN;
		public static const UP:String=Multitouch.supportsTouchEvents?TouchEvent.TOUCH_END:MouseEvent.MOUSE_UP;
		public static const MOVE:String=Multitouch.supportsTouchEvents?TouchEvent.TOUCH_MOVE:MouseEvent.MOUSE_MOVE;
		public static function TouchID(event:Event):int{
			return event.hasOwnProperty("touchPointID")?event["touchPointID"]:0;
		}		
		public static function StageX(event:Event):int{
			return event["stageX"]*Game3D.it.scaleX;
		}		
		public static function StageY(event:Event):int{
			return event["stageY"]*Game3D.it.scaleY;
		}
		public static function touch(event:Event,e:Event):Boolean{
			return event&&e&& TouchID(event)==TouchID(e);
		}
		public static function point(event:Event,e:Event):Boolean{
			return event&&e&& Math.max(Math.abs(StageX(event)-StageX(e)),Math.abs(StageY(event)-StageY(e)))<10;
		}
	}
}