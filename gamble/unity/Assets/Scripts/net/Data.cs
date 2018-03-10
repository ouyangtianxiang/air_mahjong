using System;
using System.IO;
using UnityEngine;
using System.Collections.Generic;
using System.Collections;
using LuaInterface;

namespace Game
{
    public class Data
    {
        public static Data it { private set; get; }

        public int userId;

        public Data()
        {
            it = this;
        }

        private Dictionary<string, Table> tableMap = new Dictionary<string, Table>();
        private Table[] tables = new Table[225];

        public void Connected(string ip, int port, LuaFunction fun)
        {
            ClearAllData();
            IM.it.Connected(ip, port, delegate()
            {
                fun.Call();
            });
        }

        private LuaFunction imClose;

        public void IMClose(LuaFunction imClose)
        {
            this.imClose = imClose;
        }

        public void OnClose()
        {
            if (imClose != null)
            {
                imClose.Call();
            }
        }

        public void SysData(int userId, int code, LuaFunction fun)
        {
            new ST(code, delegate()
            {
                fun.Call();
            });
        }

        public void IMCall(int code, LuaFunction fun)
        {
            IMCall(code, fun, null);
        }

        public void IMCall(int code, LuaFunction fun, LuaTable param)
        {
            object[] array = param != null ? param.ToArray() : new object[0];
            if (fun != null)
            {
                IM.it.Call(code, delegate(Buffer buffer)
                {
                    if (fun != null)
                    {
                        fun.Call(buffer);
                    }
                }, array);
            }
            else
            {
                IM.it.Call(code, array);
            }
        }

        public Table Table(string name)
        {
            return tableMap[name];
        }

        public string[] AllTable()
        {
            string[] array = new string[tableMap.Count];
            tableMap.Keys.CopyTo(array, 0);
            return array;
        }

        public void Init(Buffer buffer)
        {
            int hc = buffer.getUByte();
            if (tables[hc] == null)
            {
                string name = buffer.getUTF();
                string alias = buffer.getUTF();
                Table table = new Table(name + alias);
                table.Init(buffer);
                tableMap[table.name] = table;
                tables[hc] = table;
            }
        }

        private void ClearAllData()
        {
            tableMap.Clear();
            tables = new Table[225];
        }

        public void Insert(Buffer buffer)
        {
            int hc = buffer.getUByte();
            Table table = tables[hc];
            if (table != null)
            {
                table.Insert(buffer);
                Debug.Log("Insert" + "name:" + table.name + "hc:" + hc);
            }
        }

        public void Delete(Buffer buffer)
        {
            int hc = buffer.getUByte();
            Table table = tables[hc];
            if (table != null)
            {
                table.Delete(buffer);
                Debug.Log("Delete" + "name:" + table.name);
            }
        }

        public void Update(Buffer buffer)
        {
            int hc = buffer.getUByte();
            Table table = tables[hc];
            if (table != null)
            {
                table.Update(buffer);
                Debug.Log("Update" + "name:" + table.name);
            }
        }

        public void Desc(Bean[] array)
        {
            Array.Sort(array, new BeanComparer(false, null, null, null));
        }

        public void Desc(Bean[] array, string fname)
        {
            Array.Sort(array, new BeanComparer(false, fname, null, null));
        }

        public void Desc(Bean[] array, string fname, string fname2)
        {
            Array.Sort(array, new BeanComparer(false, fname, fname2, null));
        }

        public void Desc(Bean[] array, string fname, string fname2, string fname3)
        {
            Array.Sort(array, new BeanComparer(false, fname, fname2, fname3));
        }

        public void Asc(Bean[] array)
        {
            Array.Sort(array, new BeanComparer(true, null, null, null));
        }

        public void Asc(Bean[] array, string fname)
        {
            Array.Sort(array, new BeanComparer(true, fname, null, null));
        }

        public void Asc(Bean[] array, string fname, string fname2)
        {
            Array.Sort(array, new BeanComparer(true, fname, fname2, null));
        }


        public void Asc(Bean[] array, string fname, string fname2, string fname3)
        {
            Array.Sort(array, new BeanComparer(true, fname, fname2, fname3));
        }

        class BeanComparer : IComparer
        {
            private string fname;
            private string fname2;
            private string fname3;
            private bool asc;

            public BeanComparer(bool asc, string fname, string fname2, string fname3)
            {
                this.asc = asc;
                this.fname = fname;
                this.fname2 = fname2;
                this.fname3 = fname3;
            }

            public int Compare(object x, object y)
            {
                IComparable a;
                IComparable b;
                if (fname != null)
                {
                    a = (IComparable)((Bean)x)[fname];
                    b = (IComparable)((Bean)y)[fname];
                    if (a.Equals(b) && fname2 != null)
                    {
                        a = (IComparable)((Bean)x)[fname2];
                        b = (IComparable)((Bean)y)[fname2];
                        if (a.Equals(b) && fname3 != null)
                        {
                            a = (IComparable)((Bean)x)[fname3];
                            b = (IComparable)((Bean)y)[fname3];
                        }
                    }
                }
                else
                {
                    a = (IComparable)((Bean)x).key;
                    b = (IComparable)((Bean)y).key;
                }
                return asc ? a.CompareTo(b) : b.CompareTo(a);
            }
        }
    }
}