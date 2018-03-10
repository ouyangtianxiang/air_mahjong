
using System;
using System.Text;
using UnityEngine;

namespace Game
{
	public class Buffer
	{
		public static int SCALE = 200;

		private byte[] _data;
		private int _limit;
		private int _position;

		public Buffer ()
			: this (1024)
		{
		}

		public Buffer (int capacity)
			: this (new byte[capacity])
		{
		}

		public Buffer (byte[] bytes)
		{
			this._data = bytes;
			_position = 0;
			_limit = _data.Length;
		}

		public void flip ()
		{
			_limit = _position;
			_position = 0;
		}

		public void clear ()
		{
			_position = 0;
			_limit = _data.Length;
		}

		public int capacity {
			get {
				return _data.Length;
			}
			set {
				if (value != _data.Length) {
					byte[] tmp = _data;
					_data = new byte[value];
					Array.Copy (_data, tmp, Math.Min (_data.Length, tmp.Length));
					_position = Math.Min (value, _position);
					_limit = Math.Min (value, _limit);
				}
			}
		}

		public int limit {
			get {
				return _limit;
			}
			set {
				_limit = value;
			}
		}

		public int position {
			get {
				return _position;
			}
			set {
				_position = value;
			}
		}

		public int remaining {
			get {
				return _limit - _position;
			}
		}

		private void examinePut (int l)
		{
			while (remaining < l) {
				if (capacity - limit < l) {
					capacity *= 2;
				}
				limit = capacity;
			}
		}

		// ---------------------------------------
		public int getCode ()
		{
			int code = getUByte ();
			if (code > SCALE) {
				code = (code - SCALE) * SCALE + getUByte ();
			}
			return code;
		}

		public bool getBoolean ()
		{
			return _data [_position++] == 1;
		}

		public byte getByte ()
		{
			return _data [_position++];
		}

		public int getUByte ()
		{
			return getByte () & 0xFF;
		}

		public short getShort ()
		{
			short value = BitConverter.ToInt16 (_data, _position);
			_position += 2;
			return value;
		}

		public ushort getUShort ()
		{
			return (ushort)getShort ();
		}

		public int getInt ()
		{
			int value = BitConverter.ToInt32 (_data, _position);
			_position += 4;
			return value;
		}

		public uint getUInt ()
		{
			return (uint)getInt ();
		}

		public long getLong ()
		{
			long value = BitConverter.ToInt64 (_data, _position);
			_position += 8;
			return value;
		}

		public float getFloat ()
		{
			float value = BitConverter.ToSingle (_data, _position);
			_position += 4;
			return value;
		}

		public double getDouble ()
		{
			double value = BitConverter.ToDouble (_data, _position);
			_position += 8;
			return value;
		}

		public string getUTF ()
		{
			int len = getShort ();
			string value = Encoding.UTF8.GetString (_data, _position, len);
			_position += len;
			return value;
		}

		public object getObj (byte type)
		{
			switch (type) {
			case 0://BYTE
				return getByte ();
			case 1://SHORT
				return getShort ();
			case 2://INT
				return getInt ();
			case 3://LONG
				return getLong ();
			case 4://FLOAT
				return getFloat ();
			case 5://DOUBLE
				return getDouble ();
			case 6://STRING
				return getUTF ();
			default:
				throw new Exception ("不支持的类型" + type);
			}
		}

		public byte[] data {
			get {
				return _data;
			}
		}

		public void putCode (int value)
		{
			if (value > SCALE) {
				putByte ((byte)(SCALE + value / SCALE));
				putByte ((byte)(value % SCALE));
			} else {
				putByte ((byte)value);
			}
		}

		public void putBoolean (bool value)
		{
			examinePut (1);
			data [_position++] = (byte)(value ? 1 : 0);
		}

		public void putByte (byte value)
		{
			examinePut (1);
			data [_position++] = value;
		}

		public void putShort (short value)
		{
			examinePut (2);
			data [_position++] = (byte)(value);
			data [_position++] = (byte)(value >> 8);
		}

		public void putInt (int value)
		{
			examinePut (4);
			data [_position++] = (byte)value;
			data [_position++] = (byte)(value >> 8);
			data [_position++] = (byte)(value >> 16);
			data [_position++] = (byte)(value >> 24);
		}

		public void putUByte (short value)
		{
			putByte ((byte)value);
		}

		public void putLong (long value)
		{
			examinePut (8);
			data [_position++] = (byte)value;
			data [_position++] = (byte)(value >> 8);
			data [_position++] = (byte)(value >> 16);
			data [_position++] = (byte)(value >> 24);
			data [_position++] = (byte)(value >> 32);
			data [_position++] = (byte)(value >> 40);
			data [_position++] = (byte)(value >> 48);
			data [_position++] = (byte)(value >> 56);
		}

		public void putUShort (ushort value)
		{
			putShort ((short)value);
		}

		public void putUInt (uint value)
		{
			putInt ((int)value);
		}

		public void putFloat (float value)
		{
			examinePut (4);
			byte[] bytes = BitConverter.GetBytes (value);
			foreach (byte b in bytes) {
				data [_position++] = b;
			}
		}

		public void putDouble (double value)
		{
			examinePut (8);
			byte[] bytes = BitConverter.GetBytes (value);
			foreach (byte b in bytes) {
				data [_position++] = b;
			}
		}

		public void putBytes (byte[] value)
		{
			examinePut (value.Length);
			Array.Copy (value, 0, data, _position, value.Length);
			_position += value.Length;
		}

		public void putBuffer (Buffer value)
		{
			putBytes (value.data);
		}

		public void putUTF (String value)
		{
			byte[] b = Encoding.UTF8.GetBytes (value);
			putShort ((short)b.Length);
			putBytes (b);
		}

		public void putObj (object o, int type)
		{
			switch (type) {
			case 1:
				this.putBoolean ( Convert.ToBoolean(o) );
				break;
			case 2:
				this.putByte ( Convert.ToByte(o) );
				break;
			case 3:
				this.putShort ( Convert.ToInt16(o) );
				break;
			case 4:
				this.putInt ( Convert.ToInt32(o) );
				break;
			case 5:
				this.putLong ( Convert.ToInt64(o) );
				break;
			case 6:
				this.putFloat ( Convert.ToSingle(o) );
				break;
			case 7:
				this.putDouble ( Convert.ToDouble(o) );
				break;
			case 8:
				this.putUTF ( Convert.ToString( o) );
				break;
			case 9:
				break;
			default:
				putArray (type - 10, (Array)o);
				break;
			}
		}

		public void putArray (int[] pTypes, Array value)
		{
			if (pTypes.Length != value.Length) {
				throw new Exception ("参数不一至");
			}
			for (int i = 0; i < value.Length; i++) {
				putObj (value.GetValue (i), pTypes [i]);
			}
		}

		public void putArray (int pTypes, Array value)
		{
			this.putUByte ((short)value.Length);
			for (int i = 0; i < value.Length; i++) {
				putObj (value.GetValue (i), pTypes);
			}
		}
	}
}