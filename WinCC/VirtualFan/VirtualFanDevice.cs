using System;
using System.Net.Sockets;
using System.Threading;
using WinCC.Core;
using WinCC.Protocol;
using WinCC.Utils;

namespace WinCC.VirtualFan
{
    /// <summary>
    /// 虚拟风机设备 - 直接连接TCP服务器并发送模拟数据
    /// </summary>
    public class VirtualFanDevice : IDisposable
    {
        private readonly GatewayConfig _config;
        private TcpClient _tcpClient;
        private NetworkStream _stream;
        private Timer _reportTimer;
        private bool _isRunning;
        private readonly int _deviceId;
        private readonly int _reportInterval;

        public VirtualFanDevice(GatewayConfig config)
        {
            _config = config;
            _deviceId = config.Gateway.Id;
            _reportInterval = config.VirtualFan?.ReportInterval ?? 5000;
        }

        public void Start()
        {
            if (_isRunning) return;
            _isRunning = true;

            // 连接服务器
            ConnectToServer();

            // 启动定时上报
            _reportTimer = new Timer(OnReportTimer, null, 1000, _reportInterval);
        }

        public void Stop()
        {
            _isRunning = false;
            _reportTimer?.Dispose();
            _tcpClient?.Close();
            Logger.Instance.Info("VirtualFan stopped");
        }

        private void ConnectToServer()
        {
            try
            {
                Logger.Instance.Info("Connecting to {0}:{1}...", _config.Server.Ip, _config.Server.Port);
                _tcpClient = new TcpClient();
                _tcpClient.Connect(_config.Server.Ip, _config.Server.Port);
                _stream = _tcpClient.GetStream();
                Logger.Instance.Info("Connected to server");

                // 发送 ID 分配请求
                SendAssignId();
            }
            catch (Exception ex)
            {
                Logger.Instance.Error("Failed to connect: {0}", ex.Message);
                throw;
            }
        }

        private void SendAssignId()
        {
            // 分配 ID 请求帧 (12字节)
            // 00 00 00 00 01 00 0D 01 00 00 [CRC]
            byte[] frame = new byte[12];
            frame[0] = 0x00; frame[1] = 0x00;
            frame[2] = 0x00; frame[3] = 0x00;  // DeviceID = 0 (请求分配)
            frame[4] = 0x01;                    // DeviceModel
            frame[5] = 0x00;                    // Address
            frame[6] = 0x0D;                    // FuncCode (分配ID)
            frame[7] = 0x01; frame[8] = 0x00; // Version
            frame[9] = 0x00;                    // ParamLen

            // CRC 从 byte4 开始，长度 6
            byte[] crcBytes1 = Crc16.Calculate(frame, 4, 6);
            frame[10] = crcBytes1[0];
            frame[11] = crcBytes1[1];

            _stream.Write(frame, 0, frame.Length);
            Logger.Instance.Debug("Sent Assign ID request");

            // 读取响应
            byte[] resp = new byte[12];
            int n = _stream.Read(resp, 0, resp.Length);
            if (n > 0)
            {
                Logger.Instance.Debug("Received Assign ID response ({0} bytes)", n);
            }
        }

        private void OnReportTimer(object state)
        {
            if (!_isRunning) return;

            try
            {
                // 检查连接
                if (_tcpClient == null || !_tcpClient.Connected)
                {
                    Logger.Instance.Warn("Connection lost, reconnecting...");
                    ConnectToServer();
                }

                // 发送初始化帧
                SendInitializeFrame();

                // 发送正常运行数据帧
                SendNormalDataFrame();
            }
            catch (Exception ex)
            {
                Logger.Instance.Error("Report error: {0}", ex.Message);
            }
        }

        private void SendInitializeFrame()
        {
            // 初始化帧 (12字节)
            byte[] frame = new byte[12];
            frame[0] = 0x00; frame[1] = 0x00;
            frame[2] = 0x00; frame[3] = (byte)_deviceId;  // DeviceID
            frame[4] = 0x01;                                // DeviceModel (在线)
            frame[5] = 0x21;                                // Address 0x21
            frame[6] = 0x0F;                                // FuncCode (初始化)
            frame[7] = 0x01; frame[8] = 0x00;            // Version
            frame[9] = 0x00;                                // ParamLen

            // CRC 从 byte4 开始，长度 6
            byte[] crcBytes2 = Crc16.Calculate(frame, 4, 6);
            frame[10] = crcBytes2[0];
            frame[11] = crcBytes2[1];

            _stream.Write(frame, 0, frame.Length);
            Logger.Instance.Debug("Sent Initialize frame");
        }

        private void SendNormalDataFrame()
        {
            // 正常运行帧 (50字节)
            byte[] frame = new byte[50];

            // 帧头
            frame[0] = 0x00; frame[1] = 0x00;
            frame[2] = 0x00; frame[3] = (byte)_deviceId;  // DeviceID
            frame[4] = 0x01;                                 // DeviceModel
            frame[5] = 0x21;                                 // Address
            frame[6] = 0x41;                                 // FuncCode
            frame[7] = 0x01; frame[8] = 0x00;             // Version
            frame[9] = 0x26;                                 // ParamLen = 38

            // 数据区 (38字节)
            int idx = 10;
            // Status (4字节) - 运行中
            frame[idx++] = 0x00; frame[idx++] = 0x00;
            frame[idx++] = 0x00; frame[idx++] = 0x02;
            // Fault (4字节) - 无故障
            frame[idx++] = 0x00; frame[idx++] = 0x00;
            frame[idx++] = 0x00; frame[idx++] = 0x00;
            // Source (1字节) - AC380V
            frame[idx++] = 0x03;
            // Mode (1字节) - 风量等级模式
            frame[idx++] = 0x02;
            // RotSpeed (2字节) - 1000 rpm
            frame[idx++] = 0x03; frame[idx++] = 0xE8;
            // NTCTemp (2字节) - 40°C
            frame[idx++] = 0x00; frame[idx++] = 0x28;
            // BusVoltage (2字节) - 110V
            frame[idx++] = 0x00; frame[idx++] = 0x6E;
            // U/V/W Current (各2字节) - 3000mA
            frame[idx++] = 0x0B; frame[idx++] = 0xB8;
            frame[idx++] = 0x0B; frame[idx++] = 0xB8;
            frame[idx++] = 0x0B; frame[idx++] = 0xB8;
            // X/Y/Z Acceleration (各2字节)
            frame[idx++] = 0x00; frame[idx++] = 0x38;
            frame[idx++] = 0x00; frame[idx++] = 0x28;
            frame[idx++] = 0x00; frame[idx++] = 0x18;
            // Sum Acceleration (2字节)
            frame[idx++] = 0x00; frame[idx++] = 0x58;
            // RunTime (4字节)
            frame[idx++] = 0x00; frame[idx++] = 0x00;
            frame[idx++] = 0x4E; frame[idx++] = 0x20;
            // Version (4字节) - V1.2.3
            frame[idx++] = 0x00; frame[idx++] = 0x01;
            frame[idx++] = 0x02; frame[idx++] = 0x03;

            // CRC 从 byte5 开始，长度 43
            byte[] crcBytes3 = Crc16.Calculate(frame, 5, 43);
            frame[48] = crcBytes3[0];
            frame[49] = crcBytes3[1];

            _stream.Write(frame, 0, frame.Length);
            Logger.Instance.Debug("Sent Normal data frame (50 bytes)");
        }

        public void Dispose()
        {
            Stop();
        }
    }
}
