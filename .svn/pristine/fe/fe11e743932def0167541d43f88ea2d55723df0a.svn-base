using System;
using System.IO;
using UnityEngine;

using System.Text;

namespace Game
{
	public class ST
	{
		public delegate void Callback ();

		private Callback callback;
		private static string dataPaht = Application.persistentDataPath + "/system.data";
		private static string md5Path = Application.persistentDataPath + "/system.md5";

		public ST (int SYSDATA, Callback callback)
		{
			this.callback = callback;

			IM.it.Call (SYSDATA, onSysData, MD5 ());
		}


		private string MD5 ()
		{
			if (File.Exists (md5Path)) {
				FileStream file = File.Open (md5Path, FileMode.Open);
				byte[] bytes = new byte[file.Length];
				file.Read (bytes, 0, bytes.Length);
				file.Close ();
				return Encoding.UTF8.GetString (bytes);
			}
			return "";
		}

		private void saveMD5 (Buffer buffer)
		{
			string md5 = buffer.getUTF ();
			FileStream md5File = File.Open (md5Path, FileMode.Create);
			byte[] bytes = Encoding.UTF8.GetBytes (md5);
			md5File.Write (bytes, 0, bytes.Length);
			md5File.Close ();
		}

		private void saveData (Buffer buffer)
		{
			Inflater inflater = new Inflater ();
			inflater.SetInput (buffer.data, buffer.position, buffer.remaining);
			byte[] bytes = new byte[1024];

			FileStream outFile = File.Open (dataPaht, FileMode.Create);
			while (!inflater.IsFinished) {
				int len = inflater.Inflate (bytes);
				outFile.Write (bytes, 0, len);
			}
			outFile.Close ();
			Debug.Log (dataPaht);
		}

		private void readData ()
		{
			FileStream inFile = File.Open (dataPaht, FileMode.Open);
			byte[] data = new byte[inFile.Length];
			inFile.Read (data, 0, data.Length);
			inFile.Close ();
			Buffer buf = new Buffer (data);
			while (buf.remaining > 0) {
				Debug.Log (buf.remaining);
				IM.it.handler (buf);
			}
		}

		private void onSysData (Buffer buffer)
		{
			byte code = buffer.getByte ();
			if (code == 1) {
				saveMD5 (buffer);
				saveData (buffer);
			} 
			readData ();
			callback ();		
		}
	}
}

