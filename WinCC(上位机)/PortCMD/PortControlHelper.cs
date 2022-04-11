//操作串口收发数据
using System;
using System.IO.Ports;
using System.Text;

namespace PortCMD
{ 
    public class PortControlHelper:IDisposable
    {
        #region 字段/属性/委托
        /// <summary>
        /// 串行端口对象
        /// </summary>
        private SerialPort sp;

        /// <summary>
        /// 串口接收数据委托
        /// </summary> 
        public delegate void ComReceiveDataHandler(byte[] data);

        public ComReceiveDataHandler OnComReceiveDataHandler = null;

        /// <summary>
        /// 端口名称数组
        /// </summary>
        public string[] PortNameArr { get; set; }

        /// <summary>
        /// 串口通信开启状态
        /// </summary>
        public bool PortState { get; set; } = false;

        /// <summary>
        /// 编码类型
        /// </summary>
        //public Encoding EncodingType { get; set; } = Encoding.ASCII;
        public Encoding EncodingType { get; set; } = Encoding.UTF8;
        #endregion

        #region 方法
        public PortControlHelper()
        {
            PortNameArr = SerialPort.GetPortNames();
            sp = new SerialPort();
            sp.DataReceived += new SerialDataReceivedEventHandler(DataReceived);
        }

        /// <summary>
        /// 打开端口
        /// </summary>
        /// <param name="portName">端口名称</param>
        /// <param name="boudRate">波特率</param>
        /// <param name="dataBit">数据位</param>
        /// <param name="stopBit">停止位</param>
        /// <param name="timeout">超时时间</param>
        public void OpenPort(string portName , int boudRate = 19200, int dataBit = 8, int stopBit = 1, int timeout = 5000)
        {
            try
            {
                sp.PortName = portName;
                sp.BaudRate = boudRate;
                sp.DataBits = dataBit;
                sp.StopBits = (StopBits)stopBit;
                sp.ReadTimeout = timeout;
                sp.Open();
                PortState = true;
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        /// <summary>
        /// 关闭端口
        /// </summary>
        public void ClosePort()
        {
            try
            {
                sp.Close();
                sp.Dispose();
                sp = null;
                PortState = false;
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        /// <summary>
        /// 发送数据到
        /// </summary>
        /// <param name="sendData"></param>
        public void SendData(byte[] sendData)
        {
            try
            {
                if (sendData != null && sendData.Length > 0)
                {
                    sp.Write(sendData, 0, sendData.Length);
                }
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        /// <summary>
        /// 接收数据回调用
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DataReceived(object sender, SerialDataReceivedEventArgs e)
        {
            if (sp.BytesToRead >= 5)
            {
                byte[] buffer = new byte[sp.BytesToRead];
                sp.Read(buffer, 0, buffer.Length);
                if (OnComReceiveDataHandler != null)
                {
                    OnComReceiveDataHandler(buffer);
                }
            }
        }

        public void Dispose()
        {
            if (sp != null)
            {
                ClosePort();
            }
        }

        #endregion
    }
}
