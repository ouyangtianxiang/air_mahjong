using System;
using LuaInterface;

namespace Game
{
	public class Bean: LuaBaseRef
	{
		private LuaTable luaTable;
		private object[] _data;
		private Table table;

		public Bean (Table table)
		{
			luaTable = (LuaTable)LuaGame.it.StrToLuaTable ("{}");

			this.reference = luaTable.GetReference ();
			this.luaState = luaTable.GetLuaState ();

			this.table = table;
			luaTable ["_tableName"] = table.name;
			_data = new object[table.cols];
		}

		public void Init (Buffer buffer)
		{
			for (int i = 0; i < table.cols; i++) {
				if (table.fsync [i]) {
					_data [i] = buffer.getObj (table.ftype [i]);
					luaTable [table.fname [i]] = _data [i];
				}
			}
		}

		public Bean Init (Bean o)
		{
			if (o.table == table) {
				for (int i = 0; i < table.cols; i++) {
					_data [i] = o._data [i];
					luaTable [table.fname [i]] = _data [i];
				}
			}
			return this;
		}

		public object this [int index] {
			get {
				return _data [index];
			}
			set {
				_data [index] = value;
				luaTable [table.fname [index]] = value;
			}
		}

		public object this [string fieldName] {
			get {
				return _data [table.field (fieldName)];
			}
			set {
				_data [table.field (fieldName)] = value;
				luaTable [fieldName] = value;
			}
		}

		public object Get (string fieldName)
		{
			return _data [table.field (fieldName)];
		}

		public object key {
			get {
				byte[] keys = table.keys;
				if (keys.Length == 1) {
					return _data [keys [0]];
				} else {
					string s = "";
					foreach (int key in keys) {
						s += "-" + _data [key];
					}
					return s.Substring (1);
				}
			}
		}

		public override string ToString ()
		{
			string str = "";
			for (int i = 0; i < table.cols; i++) {
				str += "," + table.fname [i] + ":" + _data [i];
			}
			return table.name + ":(" + str.Substring (1) + ")";
		}
	}
}