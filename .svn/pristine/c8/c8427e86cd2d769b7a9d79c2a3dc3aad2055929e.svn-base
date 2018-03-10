using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using System.IO;
using System.Text;

namespace Game
{
	public class GameMain : MonoBehaviour
	{
		public static GameMain it { private set; get; }

		public string SvnURL;

		public string luaPath {
			get {
				return new DirectoryInfo ("../lua/").FullName;
			}
		}

		void Awake ()
		{
			if (SvnURL == null) {
				Debug.LogError ("SvnURL null");
			}
			it = this;
			//DontDestroyOnLoad (this.gameObject);
			Application.runInBackground = true;
			Screen.sleepTimeout = SleepTimeout.NeverSleep;
			gameObject.AddComponent<Loader> ();
			gameObject.AddComponent<Logo> ();
		}

		void Start ()
		{
		}
			
		void Update ()
		{
		}
	}
}
