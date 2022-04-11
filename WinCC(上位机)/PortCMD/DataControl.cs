using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading;

namespace PortCMD
{
    public class DataControl : IDisposable
    {
        private readonly static object locker = new object();

        private readonly static object lockerCom = new object();
        private Timer timer = null;

        private Timer HeartbeatTimer = null;


        PortControlHelper com = null;

        //在线检测是否完成
        private bool CheckOnline = false;

        //连接服务器的socket
        private Socket tcpClient = null;
        /// <summary>
        /// 接收数据的缓存
        /// </summary>
        private byte[] buffer = new byte[1024];

        /// <summary>
        /// 串口缓存
        /// </summary>
        private byte[] ComBuffer = new byte[1024];
        /// <summary>
        /// 串口缓存数据长度
        /// </summary>
        private int ComBufferlength = 0;

        //按照通信协议限定串口上传数据为37个字节长度
        private int cmdLength = 45;
        private byte[] lastData = null;

        //初始化指令
        private byte[] startData = new byte[] { 0x20, 0x01, 0x21, 0xb1, 0x82 };

        //分配临时ID指令  00 00 00 00 01 00 0D 01 00 00 22 BA
        private byte[] Init_ID  = new byte[] { 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x0D, 0x01, 0x00, 0x00, 0x22, 0xBA };

        /// <summary>
        /// 是否已经初始化获取ID号
        /// </summary>
        private bool Inited = false;


        /// <summary>
        /// 上位机账号 1 - 255 前三个字节预备扩展
        /// </summary>
        public byte CMD { get; set; } = 0x01;

        /// <summary>
        /// 服务器ip
        /// </summary>
        public string IP { get; set; }

        /// <summary>
        /// 服务器端口
        /// </summary>
        public int Port { get; set; }

        /// <summary>
        /// 显示当前数据信息
        /// </summary>
        public Action<string> ShowMessage { get; set; } = str => Console.WriteLine(DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + "  " + str);

        /// <summary>
        /// 更新临时id
        /// </summary>
        public Action<string> UpdateCMD { get; set; } 

        /// <summary>
        /// 检测在线设备的开始
        /// </summary>
        private DateTime DateTimeNow;

        private Dictionary<int, byte[]> dicOffLine = null;

        public void Dispose()
        {
            if (com != null)
            {
                com.Dispose();
                ShowMessage("关闭串口");
            }
            if (tcpClient != null)
            {
                try
                {
                    tcpClient.Dispose();
                    ShowMessage("断开服务器连接");
                }
                catch { }
            }
            if (timer != null)
            {
                try
                {
                    timer.Dispose();
                    ShowMessage("停止定时发送");
                }
                catch { }
            }
            if (HeartbeatTimer != null)
            {
                try
                {
                    HeartbeatTimer.Dispose();
                    ShowMessage("停止心跳包发送");
                }
                catch { }
            }
        }

        public DataControl()
        {
            lastData = new byte[cmdLength];
        }

        public void Init(string portName, int boudRate = 19200, int dataBit = 8, int stopBit = 1, int timeout = 3)
        {
            com = new PortControlHelper();
            com.OnComReceiveDataHandler = ComReceiveData;
            com.OpenPort(portName, boudRate, dataBit, stopBit, timeout);
            ShowMessage("串口" + portName + "连接成功");
            DateTimeNow = DateTime.Now;
            ShowMessage("开始检测在线的设备");
            InitClinet();
            ShowMessage("连接服务器成功");
            ShowMessage("向服务器申请临时ID");
            SendData(Init_ID);
            startData = null;
            timer = new Timer(o =>
            {
                if (Inited)
                {
                    lock (locker)
                    {
                        if (CheckOnline)//检测在线的设备完成开始正常的指令发送和接收
                        {
                            com.SendData(startData);
                        }
                        else
                        {
                            if (DateTime.Now.Second - DateTimeNow.Second > 5)//检测在线的设备时间默认5秒
                            {
                                lock (dicOffLine)
                                {
                                    if (dicOffLine.Count > 0)
                                    {
                                        ShowMessage("向服务器上报设备状态");
                                        foreach (var kv in dicOffLine)
                                        {
                                            SendData(kv.Value);
                                            Thread.Sleep(1000);
                                        }
                                    }
                                    dicOffLine.Clear();
                                    CheckOnline = true;
                                    ShowMessage("检测在线的设备完成");
                                }
                            }
                        }
                    }
                }
            }, null, 0, 2000);//给串口发送周期2000ms
            HeartbeatTimer = new Timer(o =>
            {
                if (Inited)
                {
                    Heartbeat();
                }

            }, null, 5000, 15 * 1000);//15秒 发一次心跳包
        }

        /// <summary>
        /// 转发串口的数据
        /// </summary>
        /// <param name="data"></param>
        private void ComReceiveData(byte[] data)
        {
            if (data != null && data.Length > 0)
            {
                if (CheckOnline)
                {
                    lock (lockerCom)
                    {
                        if (data.Length >= 0)
                        {
                            ShowMessage("收到串口" + data.Length + "个字节");
                            //打印串口数据
                            string printstr = "";
                            if (data != null)
                            {
                                for (int i = 0; i < data.Length; i++)
                                {
                                    printstr += data[i].ToString("X2");
                                }
                            }
                            ShowMessage("收到串口" + data.Length + "个字节" + printstr);


                            var cmdData = CheckComData(data);
                            if (cmdData != null)
                            {
                                if (!Equals(cmdData, lastData))
                                {
                                    SendData(cmdData);
                                    lastData = cmdData;
                                    //ShowMessage("向服务器上传" + data.Length + "个字节");
                                }
                                else
                                {
                                    ShowMessage("相同数据被忽略");
                                }
                            }
                        }
                        else
                        {
                            ShowMessage("数据格式不对被忽略");
                        }
                    }
                }
                else
                {
                    lock (dicOffLine)
                    {
                        //打印串口数据
                        string printstr = "";
                        if (data != null)
                        {
                            for (int i = 0; i < data.Length; i++)
                            {
                                printstr += data[i].ToString("X2");
                            }
                        }
                        ShowMessage("收到串口" + data.Length + "个字节" + printstr);
                        if (data[0] == 0x20 && data[1] == 0x01)
                        {
                            byte[] onlineData;
                            if (dicOffLine.TryGetValue(data[2], out onlineData))
                            {
                                onlineData[4] = 0x01;
                                var crc16 = ToModbus(onlineData, onlineData.Length - 2);
                                onlineData[10] = crc16[0];
                                onlineData[11] = crc16[1];
                                dicOffLine[data[2]] = onlineData;
                                ShowMessage("设备" + data[2].ToString("X2") + "在线！");
                            }
                        }
                    }
                }
            }
        }

        //创建socket客户端
        private void InitClinet()
        {
            //创建Socket
            tcpClient = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

            //发起建立连接请求         
            IPAddress ipaddress = IPAddress.Parse(IP);
            EndPoint point = new IPEndPoint(ipaddress, Port);

            //通过IP和端口号，定位一个要连接到的服务器端
            tcpClient.Connect(point);
            tcpClient.BeginReceive(buffer, 0, buffer.Length, SocketFlags.None, new AsyncCallback(ReceiveMessage), tcpClient);
        }

        //向服务器发送hex数据
        private void SendData(byte[] data)
        {
            if (tcpClient == null || !tcpClient.Connected)
            {
                InitClinet();
            }
            if (data != null && data.Length > 0)
            {
                if (Inited)//已经初始化获取了id
                {
                    if (data.Length == cmdLength)
                    {
                        byte[] NewData = new byte[data.Length + 5];
                        NewData[0] = 0x00;
                        NewData[1] = 0x00;
                        NewData[2] = 0x00;
                        NewData[3] = CMD;  //上位机账号 1 - 255 前三个字节预备扩展
                        NewData[4] = 0x01; //表示上位机网络在线
                        Array.Copy(data, 0, NewData, 5, data.Length);
                        ShowMessage("发送远程数据:" + ByteToString(data));
                        tcpClient.Send(NewData);
                    }
                    else
                    {
                        ShowMessage("发送远程数据:" + ByteToString(data));
                        tcpClient.Send(data);
                    }
                }
                else
                {
                    //获取上位机临时ID
                    ShowMessage("发送远程数据:" + ByteToString(data));
                    tcpClient.Send(data);
                }
            }
        }

        //给串口写入数据
        private void ReceiveMessage(IAsyncResult ar)
        {
            int length = 0;
            var socket = ar.AsyncState as Socket;
            try
            {
                length = socket.EndReceive(ar);
                if (length > 0)
                {
                    if (Inited)
                    {
                        //服务器发来 00 00 00 01时判断第四个字节 和配置文件的账号一致才接收
                        if (buffer[3] == CMD)
                        {
                            var data = new byte[length];
                            Array.Copy(buffer, 5, data, 0, length);//前四个字节为账号，第五个字节为手动/自动模式; 从第六个字节开始复制,即写给串口的数据。

                            byte[] data2 = new byte[data.Length - 5];
                            Array.Copy(data, 0, data2, 0, data2.Length);

                            startData = data2;
                            ShowMessage("向串口写入" + data2.Length + "个字节！");
                        }
                    }
                    else
                    {
                        //格式  00 00 00 01 01 00 0D 01 00 00 32 7A
                        if (buffer[0] == 0x00 && buffer[1] == 0x00 && buffer[2] == 0x00 && buffer[4] == 0x01)
                        {
                            CMD = buffer[3];
                            Inited = true;
                            if(UpdateCMD!=null)
                            {
                                UpdateCMD(CMD.ToString("X2"));
                            }
                            ShowMessage("服务器申请到临时ID为"+CMD.ToString("X2"));
                            ShowMessage("向串口写入初始化命令");
                            InitCom();
                        }
                    }
                }
                socket.BeginReceive(buffer, 0, buffer.Length, SocketFlags.None, new AsyncCallback(ReceiveMessage), socket);
            }
            catch
            {
            }
        }

        //比较 串口的两帧数据如果完全相同则不上传服务器
        private static bool Equals(byte[] newData, byte[] lastData)
        {
            if (newData.Length != lastData.Length)
            {
                return false;
            }
            else
            {
                if (newData == lastData)
                {
                    return true;
                }
                else
                {
                    for (int i = 0; i < newData.Length; i++)
                    {
                        if (newData[i] != lastData[i])
                        {
                            return false;
                        }
                    }
                }
                return true;
            }

        }

        private void InitCom()
        {
            CMDData data = new CMDData();
            dicOffLine = initOffLine();
            foreach (var d in data.first)
            {
                com.SendData(d);
                Thread.Sleep(200);
            }
            /*
            foreach (var d in data.Second)
            {
                com.SendData(d);
                Thread.Sleep(200);
            }
            */
        }

        /// <summary>
        /// 正常接收串口命令的检测
        /// </summary>
        /// <returns></returns>
        private byte[] CheckComData(byte[] ReceiveData)
        {
            if (ReceiveData != null && ReceiveData.Length > 0)
            {
                Array.Copy(ReceiveData, 0, ComBuffer, ComBufferlength, ReceiveData.Length);
                ComBufferlength += ReceiveData.Length;
            }
            if (ComBufferlength >= cmdLength)
            {
                if (ComBuffer[0] == 0x21 || ComBuffer[0] == 0x22 || ComBuffer[0] == 0x23 || ComBuffer[0] == 0x24
                    || ComBuffer[0] == 0x25 || ComBuffer[0] == 0x26 || ComBuffer[0] == 0x27 || ComBuffer[0] == 0x28)
                {
                    var data = new byte[cmdLength];
                    Array.Copy(ComBuffer, 0, data, 0, cmdLength);
                    Array.Copy(ComBuffer, cmdLength, ComBuffer, 0, ComBufferlength - cmdLength);
                    ComBufferlength -= cmdLength;
                    return data;
                }
                else
                {
                    for (int i = 0; i < ComBufferlength; i++)
                    {
                        if (ComBuffer[i] != 0x21 && ComBuffer[i] != 0x22 && ComBuffer[i] != 0x23 && ComBuffer[i] != 0x24
                                && ComBuffer[i] != 0x25 && ComBuffer[i] != 0x26 && ComBuffer[i] != 0x27 && ComBuffer[i] != 0x28)
                        {
                            continue;
                        }
                        else
                        {
                            Array.Copy(ComBuffer, i, ComBuffer, 0, ComBufferlength - i);
                            ComBufferlength -= i;
                            CheckComData(new byte[0]);
                        }
                    }
                }
            }
            return null;
        }

        private string ByteToString(byte[] data)
        {
            string str = "";
            if (data != null)
            {
                for (int i = 0; i < data.Length; i++)
                {
                    str += data[i].ToString("X2") + " ";
                }
            }
            return str;
        }

        /// <summary>
        /// 初始化设备都不在线
        /// </summary>
        /// <returns></returns>
        private Dictionary<int, byte[]> initOffLine()
        {
            Dictionary<int, byte[]> dicCom = new Dictionary<int, byte[]>();
            CMDData data = new CMDData();
            foreach (var m in data.first)
            {
                byte[] onlineData = new byte[12];
                onlineData[3] = CMD;
                onlineData[5] = m[2];
                onlineData[6] = 0x0F;
                onlineData[7] = 0x01;
                var crc16 = ToModbus(onlineData, onlineData.Length - 2);
                onlineData[10] = crc16[0];
                onlineData[11] = crc16[1];
                dicCom.Add(m[2], onlineData);
            }
            return dicCom;
        }

        private void Heartbeat()
        {
            //00 00 00 01 01 00 0E 01 00 00 32 3E
            try
            {
                if (tcpClient == null || !tcpClient.Connected)
                {
                    InitClinet();
                }
                byte[] NewData = new byte[] { 0x00, 0x00, 0x00, CMD, 0x01, 0x00, 0x0E, 0x01, 0x00, 0x00, 0x32, 0x3E };
                var crc16 = ToModbus(NewData, NewData.Length - 2);
                NewData[10] = crc16[0];
                NewData[11] = crc16[1];
                ShowMessage("向服务器发送心跳包"+ ByteToString(NewData));
                tcpClient.Send(NewData);
            }
            catch { }
        }

        /// <summary>
        /// CRC16_Modbus效验
        /// </summary>
        /// <param name="byteData">要进行计算的字节数组</param>
        /// <param name="byteLength">长度</param>
        /// <returns>计算后的数组</returns>
        public static byte[] ToModbus(byte[] byteData, int byteLength)
        {
            byte[] CRC = new byte[2];

            UInt16 wCrc = 0xFFFF;
            for (int i = 0; i < byteLength; i++)
            {
                wCrc ^= Convert.ToUInt16(byteData[i]);
                for (int j = 0; j < 8; j++)
                {
                    if ((wCrc & 0x0001) == 1)
                    {
                        wCrc >>= 1;
                        wCrc ^= 0xA001;//异或多项式
                    }
                    else
                    {
                        wCrc >>= 1;
                    }
                }
            }

            CRC[1] = (byte)((wCrc & 0xFF00) >> 8);//高位在后
            CRC[0] = (byte)(wCrc & 0x00FF);       //低位在前
            return CRC;

        }

    }
}
