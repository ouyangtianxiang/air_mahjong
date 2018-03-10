using System.IO;
using System.Text;
using LuaInterface;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using System;
using System.Security.Cryptography;

namespace Game
{

	public class Utils
	{
		private static Utils _it = new Utils ();

		public static Utils it { get { return _it; } }

		public string ReadFile (string filename)
		{
			string path = Application.persistentDataPath + "/" + filename;
			if (File.Exists (path)) {
				return File.ReadAllText (path, Encoding.UTF8);
			}
			return null;
		}

		public void SaveFile (string filename, string text)
		{
			byte[] bytes = Encoding.UTF8.GetBytes (text);
			SaveFile (filename, bytes);
		}

		public void SaveFile (string filename, byte[] bytes)
		{
			string path = Application.persistentDataPath + "/" + filename;
			FileInfo fileInfo = new FileInfo (path);
			if (!fileInfo.Directory.Exists) {
				fileInfo.Directory.Create ();
			}
			File.WriteAllBytes (path, bytes);
		}

		public GameObject CopyGameObject (GameObject gameObject)
		{
			return CopyGameObject (gameObject.transform);
		}

		public GameObject CopyGameObject (Transform transform)
		{
			GameObject go = GameObject.Instantiate (transform.gameObject);
			go.transform.SetParent (transform.parent, false);
			go.transform.localScale = Vector3.one;
			go.transform.localPosition = Vector3.zero;
			return go;
		}


		public string platform {
			get {
				switch (Application.platform) {
				case RuntimePlatform.Android:
				case RuntimePlatform.IPhonePlayer:
					return Application.platform.ToString ();
				default:
					return RuntimePlatform.WebGLPlayer.ToString ();
				}
			}
		}

		public string MD5 (string str)
		{
			return MD5 (Encoding.UTF8.GetBytes (str));
		}

		public string MD5 (byte[] bytes)
		{
			int len = Math.Min (1024 * 64, bytes.Length);
			return BitConverter.ToString ((new MD5CryptoServiceProvider ()).ComputeHash (bytes, 0, len)).ToLower ().Replace ("-", "");
		}

		public long milliseconds {
			get {
				TimeSpan ts = DateTime.Now.ToUniversalTime () - new DateTime (1970, 1, 1, 0, 0, 0, 0);
				return (long)ts.TotalMilliseconds;
			}
		}

		public void OpenApp (string packageName)
		{
			if (Application.platform == RuntimePlatform.Android) {
				AndroidJavaClass unityPlayer = new AndroidJavaClass ("com.unity3d.player.UnityPlayer");
				AndroidJavaObject activity = unityPlayer.GetStatic<AndroidJavaObject> ("currentActivity");
				AndroidJavaObject packageManager = activity.Call<AndroidJavaObject> ("getPackageManager");
				AndroidJavaObject intent = packageManager.Call<AndroidJavaObject> ("getLaunchIntentForPackage", packageName);
				activity.Call ("startActivity", intent);
			}
			if (Application.platform == RuntimePlatform.IPhonePlayer) {
				Application.OpenURL (packageName);
			}
		}
	}
}