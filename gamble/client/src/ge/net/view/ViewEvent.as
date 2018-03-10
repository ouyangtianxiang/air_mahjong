package ge.net.view
{
	import flash.events.Event;
	
	public class ViewEvent extends Event{
		public static const INSERT : String = "insert";
		public static const DELETE : String = "delete";
		public static const UPDATE : String = "update";
		public var tableName:String;
		public var key:int;
		public var fieldIndex:int;
		public var num:int;
		public var param:Array;
		public function ViewEvent(type:String,tableName:String,key:int,fieldIndex:int,num:int,param:Array){
			super(type);
			this.tableName=tableName;
			this.key=key;
			this.fieldIndex=fieldIndex;
			this.num=num;
			this.param=param;
		}
	}
}