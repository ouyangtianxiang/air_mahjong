﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class Game_LuaGameWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(Game.LuaGame), typeof(UnityEngine.MonoBehaviour));
		L.RegFunction("Mount", Mount);
		L.RegFunction("DoString", DoString);
		L.RegFunction("DoFile", DoFile);
		L.RegFunction("StrToLuaTable", StrToLuaTable);
		L.RegFunction("callLua", callLua);
		L.RegFunction("LuaGC", LuaGC);
		L.RegFunction("Close", Close);
		L.RegFunction("AddKeyListener", AddKeyListener);
		L.RegFunction("RemoveKeyListener", RemoveKeyListener);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", Lua_ToString);
		L.RegVar("it", get_it, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Mount(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			Game.LuaGame obj = (Game.LuaGame)ToLua.CheckObject(L, 1, typeof(Game.LuaGame));
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckUnityObject(L, 2, typeof(UnityEngine.GameObject));
			string arg1 = ToLua.CheckString(L, 3);
			object arg2 = ToLua.ToVarObject(L, 4);
			Game.LuaObject o = obj.Mount(arg0, arg1, arg2);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DoString(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Game.LuaGame obj = (Game.LuaGame)ToLua.CheckObject(L, 1, typeof(Game.LuaGame));
			string arg0 = ToLua.CheckString(L, 2);
			object[] o = obj.DoString(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DoFile(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Game.LuaGame obj = (Game.LuaGame)ToLua.CheckObject(L, 1, typeof(Game.LuaGame));
			string arg0 = ToLua.CheckString(L, 2);
			object[] o = obj.DoFile(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int StrToLuaTable(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Game.LuaGame obj = (Game.LuaGame)ToLua.CheckObject(L, 1, typeof(Game.LuaGame));
			string arg0 = ToLua.CheckString(L, 2);
			object o = obj.StrToLuaTable(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int callLua(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);
			Game.LuaGame obj = (Game.LuaGame)ToLua.CheckObject(L, 1, typeof(Game.LuaGame));
			LuaFunction arg0 = ToLua.CheckLuaFunction(L, 2);
			object[] arg1 = ToLua.ToParamsObject(L, 3, count - 2);
			obj.callLua(arg0, arg1);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LuaGC(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Game.LuaGame obj = (Game.LuaGame)ToLua.CheckObject(L, 1, typeof(Game.LuaGame));
			obj.LuaGC();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Close(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			Game.LuaGame obj = (Game.LuaGame)ToLua.CheckObject(L, 1, typeof(Game.LuaGame));
			obj.Close();
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddKeyListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			Game.LuaGame obj = (Game.LuaGame)ToLua.CheckObject(L, 1, typeof(Game.LuaGame));
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			int arg2 = (int)LuaDLL.luaL_checknumber(L, 4);
			obj.AddKeyListener(arg0, arg1, arg2);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveKeyListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			Game.LuaGame obj = (Game.LuaGame)ToLua.CheckObject(L, 1, typeof(Game.LuaGame));
			string arg0 = ToLua.CheckString(L, 2);
			obj.RemoveKeyListener(arg0);
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Lua_ToString(IntPtr L)
	{
		object obj = ToLua.ToObject(L, 1);

		if (obj != null)
		{
			LuaDLL.lua_pushstring(L, obj.ToString());
		}
		else
		{
			LuaDLL.lua_pushnil(L);
		}

		return 1;
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_it(IntPtr L)
	{
		try
		{
			ToLua.Push(L, Game.LuaGame.it);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}
