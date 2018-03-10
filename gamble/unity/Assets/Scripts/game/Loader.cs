using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine.UI;
using LuaInterface;

namespace Game
{
	public class Loader : MonoBehaviour
	{
		public static Loader it { private set; get; }

		public string path { private set; get; }

		void Awake ()
		{
			it = this;
			path = Application.persistentDataPath + "/" + Utils.it.platform;
			if (Application.platform == RuntimePlatform.WindowsEditor) {
				path = GameMain.it.luaPath + "WebGLPlayer";
			}
		}

		void Start ()
		{
		}

		public void TextureLoad (string filename, LuaFunction func, LuaFunction progress)
		{
			StartCoroutine (textureLoad (filename, func, progress));
		}

		private IEnumerator textureLoad (string filename, LuaFunction func, LuaFunction progress)
		{
			string uri = @"file:///" + path + "/" + filename;
			WWW www = new WWW (uri);
			while (!www.isDone) {
				progress.Call ();
				yield return new WaitForEndOfFrame ();
			}
			var ab = www.assetBundle;
			func.Call ();
		}


		public void Preload (string filename, LuaFunction func, LuaFunction progress)
		{
			Preload (filename, delegate(bool complete) {
				if (complete) {
					func.Call ();
				} else {
					progress.Call ();
				}
			});
		}

		public delegate void PreloadCallback (bool complete);

		public void Preload (string filename, PreloadCallback call)
		{
			StartCoroutine (preload (filename, call));
		}

		private AssetBundle ab;
		Dictionary<string, object> aa = new Dictionary<string, object> ();

		private IEnumerator preload (string filename, PreloadCallback call)
		{
			string uri = @"file:///" + path + "/" + filename;
			WWW www = new WWW (uri);
			while (!www.isDone) {
				call (false);
				yield return new WaitForEndOfFrame ();
			}
			ab = www.assetBundle;
			call (true);
		}


		public void WWWLoad (string url, LuaFunction fun)
		{
			WWWLoad (url, fun, null, null);
		}

		public void WWWLoad (string url, LuaFunction fun, LuaTable param)
		{
			WWWForm form = new WWWForm ();
			var dict = param.ToDictTable ();
			foreach (var o in dict) {
				form.AddField (o.Key.ToString (), o.Value.ToString ());
				Debug.Log (o.Key.ToString () + "  " + o.Value.ToString ());
			}
			WWWLoad (url, fun, null, null, form);
		}

		public void WWWLoad (string url, LuaFunction fun, string filename)
		{
			WWWLoad (url, fun, filename, null);
		}

		public void WWWLoad (string url, LuaFunction fun, string filename, LuaFunction progress)
		{
			WWWLoad (url, fun, filename, progress, null);
		}

		public void WWWLoad (string url, LuaFunction fun, string filename, LuaFunction progress, WWWForm form)
		{
			Loader.it.Load (url, delegate(WWW www) {
				fun.Call (www);
			}, filename, delegate(float value) {
				if (progress != null) {
					progress.Call (value);
				}
			}, form);
		}

		public delegate void WWWProgress (float progress);

		public delegate void WWWCallback (WWW www);

		public void Load (string url, WWWCallback callback, string filename, WWWProgress progress = null, WWWForm form = null)
		{
			Load (url, delegate(WWW www) {
				if (filename != null) {
					Utils.it.SaveFile (filename, www.bytes);
				}
				callback (www);
			}, progress, form);
		}

		public void Load (string url, WWWCallback callback, WWWProgress progress = null, WWWForm form = null)
		{
			Debug.Log (url);
			StartCoroutine (onLoad (url, callback, progress, form));
		}

		private IEnumerator onLoad (string url, WWWCallback callback, WWWProgress progress, WWWForm form = null)
		{
			WWW www = form != null ? new WWW (url, form) : new WWW (url);
			while (!www.isDone) {
				if (progress != null) {
					progress (www.progress);
				}
				yield return new WaitForEndOfFrame ();
			}
			callback (www);
		}


		private T loadImmediate<T> (string filePathName) where T : Object
		{
			if (Application.platform == RuntimePlatform.WindowsEditor) {
				//return Resources.Load<T> (filePathName);
			}
			return ab.LoadAsset<T> ("assets/res/" + filePathName.ToLower () + ".prefab");//objs [filePathName.ToLower ()];
		}

		public GameObject CreateGameObject (Transform parent, string path)
		{
			GameObject objUnit = loadImmediate<GameObject> (path);
			if (objUnit == null) {
				Debug.LogError ("load unit failed:" + path);
				return null;
			}
			GameObject obj = GameObject.Instantiate (objUnit);
			obj.transform.SetParent (parent, false);
			obj.transform.localScale = Vector3.one;
			obj.transform.localPosition = Vector3.zero;
			return obj;
		}

		public void LoadSprite (Image image, string url)
		{
			if (Application.platform == RuntimePlatform.WindowsEditor) {
				url = @"file:///" + GameMain.it.luaPath + url;
			} else {
				url = @"file:///" + Application.persistentDataPath + url;
			}
			StartCoroutine (loadSprite (image, url));
		}

		private Dictionary<string, Sprite> sprites2 = new Dictionary<string, Sprite> ();
		private Dictionary<string, WWW> spriteWWW2 = new Dictionary<string, WWW> ();
		private Dictionary<string, List<Image>> images2 = new Dictionary<string, List<Image>> ();
		private Dictionary<Image, string> imageURL = new Dictionary<Image, string> ();
		public IEnumerator loadSprite (Image image, string url)
		{
			if (sprites2.ContainsKey (url)) {
				image.sprite = sprites2 [url];
			} else {
				imageURL[image]= url;
				List<Image> list;
				if (images2.ContainsKey (url)) {
					list = images2 [url];
				} else {
					list = new List<Image> ();
					images2 [url] = list;
				}
				list.Add (image);
				if (!spriteWWW2.ContainsKey (url)) {
					WWW www = new WWW (url);
					spriteWWW2 [url] = www;
					yield return www;
					Texture2D texture = www.texture;
					Sprite sprite = Sprite.Create (texture, new Rect (0, 0, texture.width, texture.height), new Vector2 (0.5f, 0.5f));
					sprites2.Add (url, sprite);
					www.Dispose ();
					if (images2.ContainsKey (url)) {
						List<Image> lis = images2 [url];
						foreach (var img in lis) {
							if (!img.IsDestroyed ()) {
								if (imageURL.ContainsKey (img) && url.Equals (imageURL [img])) {
									img.sprite = sprite;
									imageURL.Remove (img);
								}
							}
						}
						lis.Clear ();
						images2.Remove (url);
					}
					spriteWWW2.Remove (url);
				}
			}
		}

		public void GetSprite (Image image, string name)
		{
			StartCoroutine (getSprite (image, name));
		}

		private Dictionary<string, Sprite> sprites = new Dictionary<string, Sprite> ();
		private Dictionary<string, WWW> spriteWWW = new Dictionary<string, WWW> ();
		private Dictionary<string, List<Image>> images = new Dictionary<string, List<Image>> ();

		public IEnumerator getSprite (Image image, string name)
		{
			if (sprites.ContainsKey (name)) {
				image.sprite = sprites [name];
			} else {
				int n = name.LastIndexOf ("/");
				string filename = name.Substring (0, n);
				string uri = @"file:///" + path + "/" + filename;
				List<Image> list;
				if (images.ContainsKey (name)) {
					list = images [name];
				} else {
					list = new List<Image> ();
					images [name] = list;
				}
				list.Add (image);
				if (!spriteWWW.ContainsKey (filename)) {
					WWW www = new WWW (uri);
					spriteWWW [filename] = www;
					yield return www;
					var ab = www.assetBundle;
					//var ab = AssetBundle.LoadFromFile (path + "/" + filename);
					string[] names = ab.GetAllAssetNames ();
					foreach (string _name in names) {
						string key = _name.Replace ("assets/", "");
						int end = key.LastIndexOf (".");
						key = key.Substring (0, end);
						var abr = ab.LoadAssetAsync<Sprite> (_name);
						yield return abr;
						Sprite sprite = abr.asset as Sprite;
						//Sprite sprite = ab.LoadAsset<Sprite> (_name);
						sprites.Add (key, sprite);
						if (images.ContainsKey (key)) {
							List<Image> lis = images [key];
							foreach (var img in lis) {
								if (!img.IsDestroyed ()) {
									img.sprite = sprite;
								}
							}
							lis.Clear ();
							images.Remove (key);
						}
					}
					spriteWWW.Remove (filename);
					www.Dispose ();
					ab.Unload (false);
				}
			}
		}

		public void LoadGameObject (Transform parent, string assetBundle, LuaFunction func)
		{
			LoadGameObject (assetBundle, delegate(GameObject go) {
				go.transform.SetParent (parent, false);
				go.transform.localScale = Vector3.one;
				go.transform.localPosition = Vector3.zero;
				func.Call (go);
			});
		}

		public delegate void LoadCallback (GameObject go);

		private void LoadGameObject (string assetBundle, LoadCallback callback)
		{
			StartCoroutine (loadGameObject (assetBundle, callback));
		}


		private Dictionary<string, GameObject> gos = new Dictionary<string, GameObject> ();
		private Dictionary<string, WWW> goWWW = new Dictionary<string, WWW> ();
		private Dictionary<string, List<LoadCallback>> gocallback = new Dictionary<string, List<LoadCallback>> ();

		private IEnumerator loadGameObject (string assetBundle, LoadCallback callback)
		{
			if (gos.ContainsKey (assetBundle)) {
				callback (GameObject.Instantiate (gos [assetBundle]));
			} else {
				List<LoadCallback> list;
				if (gocallback.ContainsKey (assetBundle)) {
					list = gocallback [assetBundle];
				} else {
					list = new List<LoadCallback> ();
					gocallback [assetBundle] = list;
				}
				list.Add (callback);
				if (!goWWW.ContainsKey (assetBundle)) {
					string uri = @"file:///" + path + "/" + assetBundle;
					WWW www = new WWW (uri);
					goWWW [assetBundle] = www;
					yield return www;
					var ab = www.assetBundle;
					var abr = ab.LoadAllAssetsAsync ();
					yield return abr;
					GameObject role = abr.allAssets [0] as GameObject;
					gos [assetBundle] = role;
					if (gocallback.ContainsKey (assetBundle)) {
						List<LoadCallback> lis = gocallback [assetBundle];
						foreach (var call in lis) {
							call (GameObject.Instantiate (role));
						}
						lis.Clear ();
						gocallback.Remove (assetBundle);
					}

					goWWW.Remove (assetBundle);
					www.Dispose ();
					ab.Unload (false);
				}
			}
		}

		public void LoadGameObject (string assetBundle, LuaFunction func)
		{
			LoadGameObject (assetBundle, func, null);
		}

		public void LoadGameObject (string assetBundle, LuaFunction func, object param)
		{
			LoadGameObject (assetBundle, delegate(GameObject go) {
				func.Call (go, param);
			});
		}

		public delegate void LoadCallback1 (Material go);

		private Dictionary<string, Material> ms = new Dictionary<string, Material> ();
		private Dictionary<string, WWW> msWWW = new Dictionary<string, WWW> ();
		private Dictionary<string, List<LoadCallback1>> mscallback = new Dictionary<string, List<LoadCallback1>> ();

		public void LoadMaterial (string assetBundle, LuaFunction func)
		{
			StartCoroutine (loadMaterial (assetBundle, delegate(Material go) {
				func.Call (go);
			}));

		}

		private IEnumerator loadMaterial (string assetBundle, LoadCallback1 callback)
		{
			if (ms.ContainsKey (assetBundle)) {
				callback (ms [assetBundle]);
			} else {
				List<LoadCallback1> list;
				if (mscallback.ContainsKey (assetBundle)) {
					list = mscallback [assetBundle];
				} else {
					list = new List<LoadCallback1> ();
					mscallback [assetBundle] = list;
				}
				list.Add (callback);
				if (!msWWW.ContainsKey (assetBundle)) {
					string uri = @"file:///" + path + "/" + assetBundle;
					WWW www = new WWW (uri);
					msWWW [assetBundle] = www;
					yield return www;
					var ab = www.assetBundle;
					var abr = ab.LoadAllAssetsAsync ();
					yield return abr;
					Material role = abr.allAssets [0] as Material;
					ms [assetBundle] = role;
					if (mscallback.ContainsKey (assetBundle)) {
						List<LoadCallback1> lis = mscallback [assetBundle];
						foreach (var call in lis) {
							call (Object.Instantiate (role));
						}
						lis.Clear ();
						mscallback.Remove (assetBundle);
					}

					msWWW.Remove (assetBundle);
					www.Dispose ();
					ab.Unload (false);
				}
			}
		}

		private Dictionary<string, AudioClip> dic_audioClip = new Dictionary<string, AudioClip> ();

		public void LoadAudioClip (string fileName, LuaFunction func)
		{
			if (dic_audioClip.ContainsKey (fileName)) {
				func.Call (dic_audioClip [fileName]);
			} else {
				StartCoroutine (StartLoadAudio (fileName, func));
			}
		}

		private IEnumerator StartLoadAudio (string fileName, LuaFunction func)
		{
			string pathData = @"file:///" + path + "/sound";
			WWW www = new WWW (pathData);
			yield return www;
			if (www.isDone) {
				AssetBundle ab = www.assetBundle;
				string[] assetNames = ab.GetAllAssetNames ();
				string key = string.Empty;
				foreach (var name in assetNames) {
					AssetBundleRequest abReques = ab.LoadAssetAsync<AudioClip> (name);
					yield return abReques;
					if (abReques.isDone) {
						AudioClip audioClip = abReques.asset as AudioClip;
						key = name.Replace ("assets/resources/", "").ToLower ();
						int end = key.LastIndexOf (".");
						key = key.Substring (0, end);
						dic_audioClip.Add (key, audioClip);
					}
				}
				AudioClip value = null;
				if (dic_audioClip.TryGetValue (fileName, out value)) {
					if (func != null) {
						func.Call (value);
					}
				} else {
					Debug.LogError ("资源不存在");
				}
				www.Dispose ();
				ab.Unload (false);
			}
		}
	}
}