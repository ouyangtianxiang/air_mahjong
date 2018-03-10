using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using UnityEngine;
using System.Reflection;
using System.Collections;

namespace Game
{
    public class IM : MonoBehaviour
    {
        public static IM it { private set; get; }

        public long TimeStamp
        {
            get
            {
                TimeSpan ts = DateTime.Now.ToUniversalTime() - new DateTime(1970, 1, 1, 0, 0, 0, 0);
                return (long)ts.TotalMilliseconds;
            }
        }

        private long mistiming;

        public long Time
        {
            get { return TimeStamp - mistiming; }
        }

        private Socket socket;
        private Data data;

        void Awake()
        {
            it = this;
            data = new Data();
        }

        public delegate void OnConnected();

        private OnConnected onConnected;

        public void Connected(string host, int port, OnConnected onConnected)
        {
            this.onConnected = onConnected;
            socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            socket.ReceiveBufferSize = 8192;
            socket.SendBufferSize = 8192;
            socket.NoDelay = true;
            IPAddress address = IPAddress.Parse(host);
            IPEndPoint endpoint = new IPEndPoint(address, port);

            IAsyncResult result = socket.BeginConnect(endpoint, OnConnect, socket);
            bool success = result.AsyncWaitHandle.WaitOne(5000, true);
            Debug.Log("success:" + success);
        }

        private void OnConnect(IAsyncResult asyncConnect)
        {
            Debug.Log("OnConnect:" + socket.Connected);
            if (socket.Connected)
            {
                Thread thread = new Thread(ReceiveSorket);
                thread.IsBackground = true;
                thread.Start();
            }
        }

        private Buffer lenbuf = new Buffer(4);
        private Buffer buffer = null;

        private void ReceiveSorket()
        {
            list = new List<Buffer>();
            while (socket.Connected)
            {
                try
                {
                    if (buffer != null)
                    {
                        buffer.position += socket.Receive(buffer.data, buffer.position, buffer.remaining, SocketFlags.None);
                        if (buffer.remaining == 0)
                        {
                            buffer.flip();
                            receive(buffer);
                            buffer = null;
                        }
                    }
                    else
                    {
                        lenbuf.clear();
                        if (socket.Receive(lenbuf.data, 0, 1, SocketFlags.None) == 1)
                        {
                            lenbuf.flip();
                            int len = lenbuf.getUByte();
                            lenbuf.clear();
                            if (len == 251)
                            {
                                if (socket.Receive(lenbuf.data, 0, 2, SocketFlags.None) == 2)
                                {
                                    lenbuf.flip();
                                    len = lenbuf.getUShort();
                                }
                                else
                                {
                                    break;
                                }
                            }
                            else if (len == 252)
                            {
                                if (socket.Receive(lenbuf.data, 0, 4, SocketFlags.None) == 4)
                                {
                                    lenbuf.flip();
                                    len = lenbuf.getInt();
                                }
                                else
                                {
                                    break;
                                }
                            }
                            buffer = new Buffer(len);
                        }
                        else
                        {
                            break;
                        }
                    }
                }
                catch (Exception e)
                {
                    Debug.Log("Failed to clientSocket error." + e);
                    break;
                }
            }
            Closed();
        }

        private List<Buffer> list;

        private void receive(Buffer buffer)
        {
            lock (list)
            {
                list.Add(buffer);
            }
        }

        public void Update()
        {
            if (list != null)
            {
                if (socket == null)
                {
                    data.OnClose();
                    list = null;
                }
                else
                {
                    lock (list)
                    {
                        foreach (Buffer buffer in list)
                        {
                            handler(buffer);
                        }
                        list.Clear();
                    }
                }
            }
        }

        public void handler(Buffer buffer)
        {
            int code = buffer.getCode();
            try
            {
                switch (code)
                {
                    case 0:
                        data.Init(buffer);
                        break;
                    case 1:
                        data.Insert(buffer);
                        break;
                    case 2:
                        data.Delete(buffer);
                        break;
                    case 3:
                        data.Update(buffer);
                        break;
                    case 4:
                        while (buffer.remaining > 0)
                        {
                            int c = buffer.getCode();
                            int len = buffer.getByte();
                            int[] pTypes = new int[len];
                            for (int i = 0; i < len; i++)
                            {
                                pTypes[i] = buffer.getByte();
                            }
                            PARAM_TYPE[c] = pTypes;
                        }
                        break;
                    case 5:
                        long time = buffer.getLong();
                        mistiming = TimeStamp - time;
                        onConnected();
                        break;
                    case 9:
                        throw (new Exception("ServerError:\n" + buffer.getUTF()));
                    default:
                        onCall(code, buffer);
                        break;
                }
            }
            catch (Exception e)
            {
                Debug.LogError("handler error:(" + code + ")\n" + e);
            }
        }

        public int[][] PARAM_TYPE = new int[255][];

        //关闭Socket
        public void Closed()
        {
            if (socket != null)
            {
                if (socket.Connected)
                {
                    socket.Shutdown(SocketShutdown.Both);
                    socket.Close();
                }
                socket = null;
            }
        }

        void OnApplicationQuit()
        {
            Closed();
        }

        public delegate void Callback(Buffer buffer);

        private Callback[] listeners = new Callback[255];

        public void addListener(int code, Callback callback)
        {
            listeners[code] += callback;
        }

        public void removeListener(int code, Callback callback)
        {
            listeners[code] -= callback;
            DelegateFactory.RemoveDelegate(callback);
        }

        private void onCall(int code, Buffer buffer)
        {
            int p = buffer.position;
            if (listeners[code] != null)
            {
                Delegate[] delegates = listeners[code].GetInvocationList();
                foreach (Delegate d in delegates)
                {
                    buffer.position = p;
                    d.DynamicInvoke(buffer);
                }
            }
            if (callbacks[code] != null)
            {
                buffer.position = p;
                callbacks[code](buffer);
                callbacks[code] = null;
            }
        }

        private Callback[] callbacks = new Callback[255];

        public void Call(int code, Callback callback, params object[] param)
        {
            callbacks[code] = callback;
            Call(code, param);
        }

        public void Call(int code, params object[] param)
        {
            if (socket == null)
            {
                return;
            }
            if (!socket.Connected)
            {
                socket.Close();
                return;
            }
            Buffer buffer = new Buffer();
            buffer.position = 2;
            buffer.putCode(code);
            buffer.putArray(PARAM_TYPE[code], param);
            buffer.flip();
            buffer.putShort((short)(buffer.limit - 2));
            try
            {
                IAsyncResult asyncSend = socket.BeginSend(buffer.data, 0, buffer.limit, SocketFlags.None, new AsyncCallback(SendCallback), socket);
                bool success = asyncSend.AsyncWaitHandle.WaitOne(5000, true);
                if (!success)
                {
                    socket.Close();
                    Debug.Log("Failed to SendMessage server.");
                }
            }
            catch
            {
                Debug.Log("send message error");
            }
        }

        private void SendCallback(IAsyncResult asyncConnect)
        {
            //Debug.Log("send success");
        }
    }
}