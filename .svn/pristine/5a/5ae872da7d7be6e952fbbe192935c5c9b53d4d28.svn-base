using UnityEngine;
using System.Collections;
using LuaInterface;

namespace Game
{
	public class LuaObject : MonoBehaviour
	{
		public LuaTable luaObj { private set; get; }

		private LuaFunction _start = null;
		private LuaFunction _update = null;
		private LuaFunction _lateUpdate = null;
		private LuaFunction _OnTriggerEnter = null;
		private LuaFunction _OnTriggerStay = null;
		private LuaFunction _OnControllerColliderHit = null;
		private LuaFunction _OnAnimatorIK = null;
		private LuaFunction _OnAnimEvent = null;
		private LuaFunction _destroy = null;
		public object param;

		public virtual void Awake ()
		{
			object[] re = LuaGame.it.DoFile (gameObject.name);
			luaObj = (LuaTable)re [0];
			LuaFunction _awake = luaObj.RawGetLuaFunction ("onAwake");
			_start = luaObj.RawGetLuaFunction ("onStart");
			_update = luaObj.RawGetLuaFunction ("onUpdate");
			_lateUpdate = luaObj.RawGetLuaFunction ("onLateUpdate");
			_destroy = luaObj.RawGetLuaFunction ("onDestroy");
			_OnTriggerEnter = luaObj.RawGetLuaFunction ("OnTriggerEnter");
			_OnTriggerStay = luaObj.RawGetLuaFunction ("OnTriggerStay");
			_OnControllerColliderHit = luaObj.RawGetLuaFunction ("OnControllerColliderHit");
			_OnAnimatorIK = luaObj.RawGetLuaFunction ("OnAnimatorIK");
			_OnAnimEvent = luaObj.RawGetLuaFunction ("OnAnimEvent");
			LuaGame.it.callLua (_awake, this);
		}

		public virtual void Start ()
		{
			LuaGame.it.callLua (_start, param);
		}

		public void Update ()
		{
			LuaGame.it.callLua (_update, this);
		}

		public void LateUpdate ()
		{
			LuaGame.it.callLua (_lateUpdate, this);
		}

		public void OnTriggerEnter (Collider other)
		{
			LuaGame.it.callLua (_OnTriggerEnter, other);
		}

		public void OnTriggerStay (Collider other)
		{
			LuaGame.it.callLua (_OnTriggerStay, other);
		}

		void OnControllerColliderHit (ControllerColliderHit other)
		{
			LuaGame.it.callLua (_OnControllerColliderHit, other);
		}

		void OnAnimatorIK (int layer)
		{
			LuaGame.it.callLua (_OnAnimatorIK, layer);
		}

		void OnAnimEvent (string type)
		{
			LuaGame.it.callLua (_OnAnimEvent, type);
		}

		void OnDestroy ()
		{
			LuaGame.it.callLua (_destroy);
			luaObj.Dispose ();
			GameObject.Destroy (this);
		}

		public void Destroy ()
		{
			GameObject.Destroy (gameObject);
		}
	}
}