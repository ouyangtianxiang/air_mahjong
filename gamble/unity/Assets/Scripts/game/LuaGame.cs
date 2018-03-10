using UnityEngine;
using System.Collections;
using LuaInterface;
using System.Collections.Generic;
using System;

namespace Game
{
	public class LuaGame : MonoBehaviour
	{
		public static LuaGame it { private set; get; }

		private LuaState lua;
		private LuaLooper loop;

		void Awake ()
		{
			it = this;
		}

		void Start ()
		{
			lua = new LuaState ();
			lua.LuaSetTop (0);
			LuaCoroutine.Register (lua, this);
			LuaBinder.Bind (lua);
			DelegateFactory.Register ();
			lua.Start ();

			loop = gameObject.AddComponent<LuaLooper> ();
			loop.luaState = lua;

			gameObject.AddComponent<LuaObject> ();
		}

		public LuaObject Mount (GameObject gameObject, string name, object param)
		{
			gameObject.name = name;
			LuaObject obj = gameObject.AddComponent<LuaObject> ();
			obj.param = param;
			return obj;
		}

		public object[] DoString (string str)
		{
			return lua.DoString (str);
		}

		public object[] DoFile (string fileName)
		{
			return lua.DoFile (fileName);
		}

		public object StrToLuaTable (string str)
		{
			return lua.DoString ("return " + str) [0];
		}

		public void callLua (LuaFunction fun, params object[] param)
		{
			if (fun != null) {
				fun.Call (param);
			}
		}

		public void LuaGC ()
		{
			lua.LuaGC (LuaGCOptions.LUA_GCCOLLECT);
		}

		public void Close ()
		{
			loop.Destroy ();
			loop = null;

			lua.Dispose ();
			lua = null;
		}

		private Dictionary<string,KeyValuePair<int,LuaFunction>> keys = new Dictionary<string, KeyValuePair<int,LuaFunction>> ();

		public void AddKeyListener (string key, LuaFunction onKey, int type)
		{
			keys.Add (key, new KeyValuePair<int, LuaFunction> (type, onKey));
		}

		public void RemoveKeyListener (string key)
		{
			keys.Remove (key);
		}

		void Update ()
		{
			foreach (var key in keys) {
				var e = key.Value;
				switch (e.Key) {
				case 0:
					if (Input.GetKeyDown (key.Key)) {
						e.Value.Call ();
					}
					break;
				case 1:
					if (Input.GetKey (key.Key)) {
						e.Value.Call ();
					}
					break;
				case 2:
					if (Input.GetKeyUp (key.Key)) {
						e.Value.Call ();
					}
					break;
				}
			}
		}
	}
}