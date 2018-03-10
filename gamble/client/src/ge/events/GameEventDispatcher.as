package ge.events{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class GameEventDispatcher{
		private var eventListeners:Dictionary;
		
		public function GameEventDispatcher(){
		}
		
		public function addEventListener(type:String, listener:Function):void{
			if (eventListeners == null){
				eventListeners = new Dictionary();
			}
			var listeners:Dictionary = eventListeners[type];
			if (listeners == null){
				listeners=new Dictionary();
				eventListeners[type] =listeners;
			}
			listeners[listener]=listener
		}
		
		public function removeEventListener(type:String, listener:Function):void{
			if (eventListeners){
				var listeners:Dictionary = eventListeners[type];
				if (listeners){
					delete listeners[listener];
				}
			}
		}
		private static const DOWNS:Array=[];
		private var _touchID:int=-1;
		private var _touchX:int=-1;
		private var _touchY:int=-1;
		public function get touchID():int{
			return _touchID;
		}
		public function get touchX():int{
			return _touchX;
		}
		public function get touchY():int{
			return _touchY;
		}
		
		public static function ReleaseAll():void{
			var evnet:Event=new Event(GameEvent.UP);
			for each (var dic:Dictionary in DOWNS) {
				for each (var o:GameEventDispatcher in dic){
					o.release(evnet);
				}
			}
		}
		
		public static function Release(event:Event):void{
			var dic:Dictionary=DOWNS[GameEvent.TouchID(event)];
			for each (var o:GameEventDispatcher in dic){
				o.release(event);
			}
		}
		
		public static function Press(event:Event):void{
			DOWNS[GameEvent.TouchID(event)]=new Dictionary
		}
		
		private function press(event:Event):void{
			_touchID=GameEvent.TouchID(event);
			_touchX=GameEvent.StageX(event);
			_touchY=GameEvent.StageY(event);
			var dic:Dictionary=DOWNS[_touchID];
			dic[this]=this;
		}
		
		private function release(event:Event):void{
			if(_touchID>=0){
				_touchID=-1;
				invokeEvent(event.type);
			}
		}
		
		public function dispatchEvent(event:Event):void{
			if (eventListeners){
				if(event.type==GameEvent.DOWN){
					if(_touchID>=0){
						return;
					}
					press(event);
				}
				invokeEvent(event.type);
				if(event.type==GameEvent.UP && _touchID==GameEvent.TouchID(event)){
					invokeEvent(GameEvent.CLICK);
					_touchID=-1;
				}
			}
		}
		
		private function invokeEvent(type:String):void{
			var listeners:Dictionary = eventListeners[type];
			for each (var fun:Function in listeners){
				fun(this);
			}
		}
	}
}