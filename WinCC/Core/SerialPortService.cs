using System;
using System.IO.Ports;
using System.Text;
using System.Threading;
using WinCC.Utils;
using WinCC.Protocol;

namespace WinCC.Core
{
    public class SerialPortService : IDisposable
    {
        private SerialPort _serialPort;
        private readonly object _lock = new object();
        private bool _isOpen;

        public event Action<byte[]> OnDataReceived;
        public event Action<string> OnError;
        public event Action OnOpened;
        public event Action OnClosed;

        public bool IsOpen => _isOpen;
        public string PortName { get; private set; }

        /// <summary>
        /// 打开串口
        /// </summary>
        public void Open(string portName, int baudRate = 19200, int dataBits = 8, int stopBits = 1, int parity = 0, int readTimeout = 3000, int writeTimeout = 3000)
        {
            lock (_lock)
            {
                if (_isOpen)
                {
                    Close();
                }

                try
                {
                    PortName = portName;
                    _serialPort = new SerialPort(
                        portName,
                        baudRate,
                        (Parity)parity,
                        dataBits,
                        (StopBits)stopBits
                    );

                    _serialPort.ReadTimeout = readTimeout;
                    _serialPort.WriteTimeout = writeTimeout;
                    _serialPort.DataReceived += DataReceivedHandler;

                    _serialPort.Open();
                    _isOpen = true;

                    Logger.Instance.Info("Serial port {0} opened (BaudRate={1}, DataBits={2}, StopBits={3})",
                        portName, baudRate, dataBits, stopBits);

                    OnOpened?.Invoke();
                }
                catch (Exception ex)
                {
                    Logger.Instance.Error("Failed to open serial port {0}: {1}", portName, ex.Message);
                    _isOpen = false;
                    throw;
                }
            }
        }

        /// <summary>
        /// 关闭串口
        /// </summary>
        public void Close()
        {
            lock (_lock)
            {
                if (!_isOpen || _serialPort == null)
                {
                    return;
                }

                try
                {
                    _serialPort.DataReceived -= DataReceivedHandler;
                    _serialPort.Close();
                    _serialPort.Dispose();
                    _serialPort = null;
                    _isOpen = false;

                    Logger.Instance.Info("Serial port {0} closed", PortName);
                    OnClosed?.Invoke();
                }
                catch (Exception ex)
                {
                    Logger.Instance.Error("Error closing serial port: {0}", ex.Message);
                }
            }
        }

        /// <summary>
        /// 发送数据
        /// </summary>
        public void Send(byte[] data)
        {
            lock (_lock)
            {
                if (!_isOpen || _serialPort == null)
                {
                    Logger.Instance.Warn("Cannot send data: serial port not open");
                    return;
                }

                if (data == null || data.Length == 0)
                {
                    return;
                }

                try
                {
                    _serialPort.Write(data, 0, data.Length);
                    Logger.Instance.Debug("[SERIAL OUT] {0}", Crc16.ToHexString(data));
                }
                catch (Exception ex)
                {
                    Logger.Instance.Error("Error sending data to serial port: {0}", ex.Message);
                    OnError?.Invoke(ex.Message);
                }
            }
        }

        /// <summary>
        /// 串口数据接收处理
        /// </summary>
        private void DataReceivedHandler(object sender, SerialDataReceivedEventArgs e)
        {
            lock (_lock)
            {
                if (!_isOpen || _serialPort == null)
                {
                    return;
                }

                try
                {
                    int bytesToRead = _serialPort.BytesToRead;
                    if (bytesToRead > 0)
                    {
                        byte[] buffer = new byte[bytesToRead];
                        _serialPort.Read(buffer, 0, bytesToRead);

                        Logger.Instance.Debug("[SERIAL IN] {0}", Crc16.ToHexString(buffer));

                        OnDataReceived?.Invoke(buffer);
                    }
                }
                catch (Exception ex)
                {
                    Logger.Instance.Error("Error reading from serial port: {0}", ex.Message);
                    OnError?.Invoke(ex.Message);
                }
            }
        }

        /// <summary>
        /// 获取可用串口列表
        /// </summary>
        public static string[] GetAvailablePorts()
        {
            return SerialPort.GetPortNames();
        }

        public void Dispose()
        {
            Close();
        }
    }
}
