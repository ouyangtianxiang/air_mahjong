using System;
using System.Collections.Generic;
using JetBrains.Annotations;
using UnityEngine;

namespace Game
{
    public class Where
    {
        public static Where[] toWhere(params object[] param)
        {
            List<string> str = new List<string>();

            for (int j = 0; j < param.Length; j++)
            {
                if (param[j] != null)
                {
                    str.Add(param[j].ToString());
                }
            }
            Where[] where = new Where[str.Count];
            for (int i = 0; i < str.Count; i++)
            {
                where[i] = new Where(str[i].ToString());

            }
            return where;
        }
        private string i;
        private string k;
        private string v;
        public Where(string where)
        {
            string[] kv = null;
            kv = where.Split('!');
            if (kv != null && kv.Length == 2)
            {
                i = "!";
                k = kv[0];
                v = kv[1];
                return;
            }
            kv = where.Split('=');
            if (kv != null && kv.Length == 2)
            {
                i = "=";
                k = kv[0];
                v = kv[1];
                return;
            }
            kv = where.Split('<');
            if (kv != null && kv.Length == 2)
            {
                i = "<";
                k = kv[0];
                v = kv[1];
                return;
            }
            kv = where.Split('>');
            if (kv != null && kv.Length == 2)
            {
                i = ">";
                k = kv[0];
                v = kv[1];
                return;
            }
        }

        public Boolean fairly(Bean o)
        {
            var value = o[k];
            double r = 0;
            if (value is string)
            {
                r = String.CompareOrdinal(value.ToString(), v);
            }
            else if (value is byte || value is short || value is int || value is long || value is float || value is double)
            {
                r = double.Parse(value.ToString()) - double.Parse(v);
            }
            else
            {
                Debug.LogError("不支持的类型" + value.GetType());
            }

            switch (i)
            {
                case "!":
                    return r != 0;
                case "=":
                    return r == 0;
                case "<":
                    return r < 0;
                case ">":
                    return r > 0;
                default:
                    return false;
            }
        }
    }
}