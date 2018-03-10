package ge.net {
	import ge.net.type.Code;
	import ge.net.type.byte;
	import ge.net.type.double;
	import ge.net.type.float;
	import ge.net.type.short;

	import flash.utils.ByteArray;
	import flash.utils.Endian;

	/**
	 * @author Administrator
	 */
	public class Buffer extends ByteArray {
		private static const scale : int = 200;

		public function Buffer() {
			endian = Endian.LITTLE_ENDIAN;
		}

		public function writeCode(code : int) : void {
			if (code > scale) {
				writeByte(scale + code / scale);
				writeByte(code % scale);
			} else {
				writeByte(code);
			}
		}

		public function readCode() : int {
			var code : int = readUnsignedByte();
			if (code > scale) {
				code = (code - scale) * scale + readUnsignedByte();
			}
			return code;
		}

		public function writeArray(param : Array) : void {
			var len : int = param.length;
			for (var i : int = 0;i < len;i++) {
				writeObj(param[i]);
			}
		}

		public function writeObj(obj : *) : void {
			if (obj is Boolean) {
				writeBoolean(obj);
			} else if (obj is byte) {
				writeByte(obj);
			} else if (obj is short) {
				writeShort(obj);
			} else if (obj is int) {
				writeInt(obj);
			} else if (obj is Code) {
				writeCode(obj);
			} else if (obj is float) {
				writeFloat(obj);
			} else if (obj is double) {
				writeDouble(obj);
			} else if (obj is String) {
				writeUTF(obj);
			} else if (obj is Array) {
				writeByte((obj as Array).length);
				writeArray(obj);
			} else {
				throw new Error("类型不支持");
			}
		}

		public function readObj(type : int) : * {
			switch (type) {
				case 1:
					return readByte();
					break;
				case 2:
					return readShort();
					break;
				case 3:
					return readInt();
					break;
				case 4:
					return readFloat();
					break;
				case 5:
					return readDouble();
					break;
				case 6:
					return readUTF();
					break;
				default:
					throw new Error("类型不支持");
			}
		}
	}
}
