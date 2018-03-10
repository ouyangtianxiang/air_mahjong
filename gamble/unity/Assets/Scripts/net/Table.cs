using System;
using System.Collections.Generic;
using UnityEngine;
using System.Collections;

namespace Game
{
	public enum TableEvent
	{
		INSERT,
		DELETE,
		UPDATE
	}

	public class Table
	{

		public string name { private set; get; }

		public short cols { private set; get; }

		public string[] fname { private set; get; }

		private Dictionary<string, byte> fnamedic = new Dictionary<string, byte> ();

		public byte[] ftype { private set; get; }

		public bool[] fsync { private set; get; }

		public byte[] keys { private set; get; }

		private Dictionary<object, Bean> _data = new Dictionary<object, Bean> ();


		public Table (string name)
		{
			this.name = name;
		}

		public byte field (string name)
		{
			return fnamedic [name];
		}

		public string keyName {
			get {
				string s = "";
				foreach (int key in keys) {
					s += "-" + fname [key];
				}
				return s.Substring (1);
			}
		}

		public void Init (Buffer buffer)
		{
			byte klen = buffer.getByte ();
			keys = new byte[klen];
			for (int i = 0; i < klen; i++) {
				keys [i] = buffer.getByte ();
			}

			cols = buffer.getShort ();
			fname = new string[cols];
			ftype = new byte[cols];
			fsync = new bool[cols];

			for (byte i = 0; i < cols; i++) {
				fname [i] = buffer.getUTF ();
				fnamedic [fname [i]] = i;
				ftype [i] = buffer.getByte ();
				fsync [i] = buffer.getBoolean ();
			}
			Debug.Log ("Init" + "name:" + name);
		}

		public void Insert (Buffer buffer)
		{
			int rows = buffer.getShort ();
			for (int r = 0; r < rows; r++) {
				Bean obj = new Bean (this);
				obj.Init (buffer);
				object k = obj.key;
				if (_data.ContainsKey (k)) {
					obj = _data [k].Init (obj);
				} else {
					_data [k] = obj;
				}
				dispatchEvent (TableEvent.INSERT, obj);
			}
		}

		private void dispatchEvent (TableEvent te, Bean obj)
		{
			if (listeners [(int)te] != null) {
				listeners [(int)te] (obj);
			}
		}

		public void Delete (Buffer buffer)
		{
			if (buffer.limit > buffer.position) {
				int len = buffer.getShort ();
				for (int i = 0; i < len; i++) {
					object k = buffer.getObj (ftype [keys [0]]);
					if (_data.ContainsKey (k)) {
						Bean obj = _data [k];
						_data.Remove (k);
						dispatchEvent (TableEvent.DELETE, obj);
					}
				}
			} else { //清空表
				foreach (var o in _data) {
					dispatchEvent (TableEvent.DELETE, o.Value);
				}
				_data.Clear ();
			}
		}

		public void Update (Buffer buffer)
		{
			object k = buffer.getObj (ftype [keys [0]]);
			if (_data.ContainsKey (k)) {
				Bean obj = _data [k];
				while (buffer.position < buffer.limit) {
					int i = buffer.getUByte ();
					obj [i] = buffer.getObj (ftype [i]);
				}
				dispatchEvent (TableEvent.UPDATE, obj);
			}

		}

		public delegate void Callback (Bean t);

		private Callback[] listeners = new Callback[3];

		public void addListener (TableEvent te, Callback callback)
		{
			listeners [(int)te] += callback;
		}

		public void removeListener (TableEvent te, Callback callback)
		{
			listeners [(int)te] -= callback;
			DelegateFactory.RemoveDelegate (callback);
		}

		public Bean Get ()
		{
			foreach (var o in _data) {
				return o.Value;
			}
			return null;
		}

		public object getK2K (object v)
		{
			if (keys.Length == 1) {
				switch (ftype [keys [0]]) {
				case 0://BYTE
                        return Convert.ToByte(v);
				case 1://SHORT
                        return Convert.ToInt16(v);
				case 2://INT
                        return Convert.ToInt32(v);
				case 3://LONG
                        return Convert.ToInt64(v);
				case 4://FLOAT
                        return Convert.ToSingle(v);
				case 5://DOUBLE
                        return Convert.ToDouble(v);
				case 6://STRING
                        return Convert.ToString(v);
				default:
					throw new Exception ("不支持的类型" + v);
				}
			}
			return (string)v;
		}

		public Bean Get (object key)
		{
			key = getK2K (key);
			return _data.ContainsKey (key) ? _data [key] : null;
		}


		public Bean[] Get (bool and)
		{
			return Get (and, null, null, null, null);
		}

		public Bean[] Get (bool and, string param)
		{
			return Get (and, param, null, null, null);
		}

		public Bean[] Get (bool and, string param, string param1)
		{
			return Get (and, param, param1, null, null);
		}

		public Bean[] Get (bool and, string param, string param1, string param2)
		{
			return Get (and, param, param1, param2, null);
		}

		public Bean[] Get (bool and, string param, string param1, string param2, string param3)
		{
			Where[] whs = Where.toWhere (param, param1, param2, param3);
			int len = whs.Length;
			List<Bean> list = new List<Bean> ();
			foreach (var item in _data) {
				int n = 0;
				foreach (Where wh in whs) {
					if (wh.fairly (item.Value)) {
						n++;
					}
				}
				if (len == 0 || and ? n == len : n > 0) {
					list.Add (item.Value);
				}
			}
			return list.ToArray ();
		}

		public Bean[] GetAll ()
		{
			List<Bean> list = new List<Bean> (_data.Count);
			foreach (var o in _data) {
				list.Add (o.Value);
			}
			return list.ToArray ();
		}
	}
}