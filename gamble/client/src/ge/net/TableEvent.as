package ge.net {
	import flash.utils.Dictionary;
	

	/**
	 * @author tianxiang.ouyang
	 */
	public class TableEvent {
		public static const INSERT : String = "insert";
		public static const DELETE : String = "delete";
		public static const UPDATE : String = "update";
		public var type:String;
		public var table : Table;
		public var key : *;
		public var obj : Bean;
		public var old : *;

		public function TableEvent(table : Table) {
			this.table = table;
		}
		
		private var listeners:Object={};
		public function addEventListener(type:String,listener:Function):void{
			var dic:Dictionary=listeners[type];
			if(dic==null){
				dic=new Dictionary();
				listeners[type]=dic;
			}
			dic[listener]=listener;
		}
		
		public function removeEventListener(type:String,listener:Function):void{
			var dic:Dictionary=listeners[type];
			if(dic){
				delete dic[listener];
			}
		}
		
		public static var DE:Boolean=true;
		public function dispatchEvent(type : String, key : * = null, obj : Bean = null,old:*=null):void{
			if(DE){
				this.type=type;
				this.key = key;
				this.obj = obj;
				this.old = old;
				var dic:Dictionary=listeners[type];
				for each (var listener:Function in dic) {
					listener(this);
				}
			}
		}
		public function clear() : void {
			listeners={};
		}
	}
}
