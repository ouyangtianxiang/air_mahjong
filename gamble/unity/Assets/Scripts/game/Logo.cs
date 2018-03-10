using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using System;
using System.IO;

namespace Game
{
	public class Logo : MonoBehaviour
	{

		public string path { private set; get; }

		private string url;

		void Awake ()
		{
			path = Application.persistentDataPath + "/" + Utils.it.platform;
			if (Application.platform == RuntimePlatform.WindowsEditor) {
				path = GameMain.it.luaPath + "WebGLPlayer";
				Debug.Log (path);
			}
		}

		void Start ()
		{
			StartLoad ();
		}

		private void StartLoad ()
		{
			Loader.it.Load (GameMain.it.SvnURL, onURL);
		}

		private void onURL (WWW www)
		{
			if (www.text == null || www.text.Length == 0) {
				StartLoad ();
				return;
			}
			url = www.text.Trim ();

			if (Application.platform == RuntimePlatform.WindowsEditor) {
				url = @"file:///" +GameMain.it.luaPath;
			}	
			Loader.it.Load (url + "version", OnVersion);
		}

		private string newVersion;

		private void OnVersion (WWW www)
		{
			if (www.text == null || www.text.Length == 0) {
				StartLoad ();
				return;
			}
			newVersion = www.text;
			string version = Utils.it.ReadFile ("version");
			Debug.Log (newVersion + "  " + version);
			if (newVersion.Equals (version)) {
				InitLua ();
			} else {
				Loader.it.Load (url + Utils.it.platform + ".version", OnVersionInfo);
			}
		}

		Dictionary<string,KeyValuePair<string,int>> map1;

		private void OnVersionInfo (WWW www)
		{
			if (www.text == null || www.text.Length == 0) {
				StartLoad ();
				return;
			}

			map1 = toMap (www.text);

			string localVersionInfo = Utils.it.ReadFile ("versionInfo");
			Dictionary<string,KeyValuePair<string,int>> map2 = toMap (localVersionInfo);
			foreach (var item1 in map2) {
				if (map1.ContainsKey (item1.Key)) {
					var o = map1 [item1.Key];
					if (item1.Value.Key.Equals (o.Key) && item1.Value.Value == o.Value) {
						map1.Remove (o.Key);
					} else {
						byteNum += o.Value;
					}
				}
			}

			fileNum += map1.Count;
			Load ();

		}

		private Dictionary<string,KeyValuePair<string,int>> toMap (string str)
		{
			string[] sps = str.Split (new char[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
			Dictionary<string,KeyValuePair<string,int>> map = new Dictionary<string, KeyValuePair<string,int>> ();

			foreach (string sp in sps) {
				string[] s = sp.Split (new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
				map.Add (s [0], new KeyValuePair<string,int> (s [1], int.Parse (s [2])));
			}
			return map;
		}


		private int byteNum = 0;
		private int fileNum = 0;
		private string filename;

		private void OnLoad (WWW www)
		{
			if (www.error == null) {
				map1.Remove (filename);
			}
			Load ();
		}

		private void OnProgress (float progrees)
		{
			Debug.Log (progrees+"%%%%%%%%%%%%%%%");
		}

		private void Load ()
		{
			foreach (var item in map1) {
				filename = item.Key;
				Loader.it.Load (url + filename, OnLoad, filename, OnProgress);
				return;
			}

			Debug.Log ("version:"+ newVersion);
			Utils.it.SaveFile ("version", newVersion);
			InitLua ();					
		}

		private void InitLua ()
		{
			gameObject.AddComponent<LuaGame> ();
			Destroy (this);
		}
	}
}