package ge.net {
	import flash.utils.getDefinitionByName;
	
	/**
	 * @author txoy
	 */
	public class Table {
		public static const array : Array = new Array();
		
		internal static function Init(buffer : Buffer) : void {
			var hc : int = buffer.readUnsignedByte();
			var name : String = buffer.readUTF();
			var alias : String = buffer.readUTF();
			var table : Table;
			if (alias.length > 0) {
				table = getDefinitionByName("game.data.bean." + name)["view"](alias);
			} else {
				table = getDefinitionByName("game.data.bean." + name)["table"];
			}
			if (hc == 0) {
				array[name] = table;
			}
			array[hc] = table;
			trace("Init", "name:", table.name, "hc:", hc);
		}
		
		internal static function Insert(buffer : Buffer) : void {
			var hc : int = buffer.readUnsignedByte();
			var table : Table = array[hc];
			if (table != null) {
				table.insert(buffer);
				trace("Insert", "name:", table.name, "hc:", hc);
			}
		}
		
		internal static function Delete(buffer : Buffer) : void {
			var hc : int = buffer.readUnsignedByte();
			var table : Table = array[hc];
			if (table != null) {
				table.del(buffer);
				trace("Delete", "name:", table.name);
			}
		}
		
		internal static function Update(buffer : Buffer) : void {
			var hc : int = buffer.readUnsignedByte();
			var table : Table = array[hc];
			if (table != null) {
				table.update(buffer);
				trace("Update", "name:", table.name);
			}
		}
		
		public var C : Class;
		public var keys : Array = [];
		public var types : Array = [];
		public var names : Array = [];
		public var maps : Array = [];
		private var data : Object = new Object();
		private var event : TableEvent;
		public var name : String
		public var alias : String
		
		public function Table(c : Class, alias : String = null) {
			C = c;
			types = C["types"];
			names = C["names"];
			maps = C["maps"];
			keys = C["keys"];
			var str : String = String(C);
			name = str.substring(7, str.length - 1);
			if (alias) {
				name += "_" + alias;
			}
			this.alias = alias;
			event = new TableEvent(this);
		}
		
		private var rows : int = 0;
		
		public function get size() : int {
			return rows;
		}
		
		private function insert(buffer : Buffer) : void {
			var rows : int = buffer.readShort();
			for (var r : int = 0; r < rows; r++) {
				var obj : Bean = new C();
				obj.Init(this);
				var cols : int = types.length;
				for (var i : int = 0; i < cols; i++) {
					if (maps[i]) {
						obj[names[i]] = buffer.readObj(types[i]);
					}
				}
				var k : * = obj.key;
				var o : Bean = data[k];
				if (o) {
					obj = o._value(obj);
				} else {
					data[k] = obj;
					this.rows++;
				}
				event.dispatchEvent(TableEvent.INSERT, k, obj);
			}
		}
		
		private function del(buffer : Buffer) : void {
			if (buffer.length > buffer.position) {
				var len : int = buffer.readShort();
				for (var i : int = 0; i < len; i++) {
					var id : int = buffer.readObj(types[keys[0]]);
					var o : Bean = data[id];
					if (o != null) {
						this.rows--;
						delete data[id];
						event.dispatchEvent(TableEvent.DELETE, id, o);
					}
				}
			} else { //清空表
				for (var k : * in data) {
					delete data[k];
					this.rows--;
				}
				event.dispatchEvent(TableEvent.DELETE, this);
			}
		}
		
		private function update(buffer : Buffer) : void {
			var k : int = buffer.readObj(types[keys[0]]);
			var obj : Bean = data[k];
			while (buffer.position < buffer.length) {
				var i : int = buffer.readUnsignedByte();
				var name : String = names[i];
				var old : * = obj[name];
				obj[name] = buffer.readObj(types[i]);
				event.dispatchEvent(name, k, obj, old);
			}
			event.dispatchEvent(TableEvent.UPDATE, k, obj);
		}
		
		public function getObj(key : * = null) : * {
			if (key == null) {
				for each (var o : * in data) {
					return o;
				}
			}
			return data[key];
		}
		
		public function getList(and : Boolean, ... where : *) : Array {
			var whs : Array = Where.toWhere(where);
			var len : int = whs.length;
			var array : Array = [];
			for each (var o : Bean in data) {
				var n : int = 0;
				for each (var wh : Where in whs) {
					if (wh.fairly(o)) {
						n++;
					}
				}
				if (len == 0 || and ? n == len : n > 0) {
					array.push(o);
				}
			}
			return array;
		}
		
		public function addEventListener(type : String, listener : Function) : void {
			event.addEventListener(type, listener);
		}
		
		public function removeEventListener(type : String, listener : Function) : void {
			event.removeEventListener(type, listener);
		}
		
		public function clear() : void {
			data = {};
			rows = 0;
			event.clear();
		}
		
		public static function Dispose(isAll : Boolean = false) : void {
			for (var i : int = 0; i < array.length; i++) {
				var table : Table = array[i];
				if (table) {
					if (isAll) {
						table.clear();
					} else {
						if (table.name.charAt(0) != "S") {
							table.clear();
						}
					}
				}
			}
		}
	}
}
