using System;
using System.Threading;
using WinCC.Utils;
using WinCC.Protocol;

namespace WinCC.Core
{
    /// <summary>
    /// 网关核心 - 被动透传，无业务逻辑
    /// </summary>
    public class Gateway : IDisposable
    {
        private readonly SerialPortService _serial;
        private readonly TcpClientService _tcp;
        private readonly GatewayConfig _config;
        private readonly FrameParser _serialParser;
        private readonly FrameParser _tcpParser;
        private Timer _heartbeatTimer;
        private bool _isRunning;

        public Gateway(GatewayConfig config)
        {
            _config = config ?? throw new ArgumentNullException(nameof(config));
            _serial = new SerialPortService();
            _tcp = new TcpClientService();
            _serialParser = new FrameParser();
            _tcpParser = new FrameParser();

            // 串口 -> TCP 事件绑定
            _serial.OnDataReceived += HandleSerialData;
            _serial.OnError += (msg) => Logger.Instance.Error("[SERIAL ERROR] {0}", msg);

            // TCP -> 串口 事件绑定
            _tcp.OnDataReceived += HandleTcpData;
            _tcp.OnError += (msg) => Logger.Instance.Error("[TCP ERROR] {0}", msg);
            _tcp.OnDisconnected += () => Logger.Instance.Warn("TCP disconnected, reconnecting...");
            _tcp.OnConnected += () =>
            {
                Logger.Instance.Info("TCP connected");
                StartHeartbeat();
            };
        }

        /// <summary>
        /// 启动网关
        /// </summary>
        public void Start()
        {
            if (_isRunning) return;

            Logger.Instance.Info("Starting Gateway...");
            _isRunning = true;

            // 打开串口
            try
            {
                _serial.Open(
                    _config.Gateway.Serial.Port,
                    _config.Gateway.Serial.BaudRate,
                    _config.Gateway.Serial.DataBits,
                    _config.Gateway.Serial.StopBits,
                    _config.Gateway.Serial.Parity,
                    _config.Gateway.Serial.ReadTimeout,
                    _config.Gateway.Serial.WriteTimeout
                );
            }
            catch (Exception ex)
            {
                Logger.Instance.Fatal("Failed to open serial port: {0}", ex.Message);
                throw;
            }

            // 连接TCP服务器
            _tcp.Connect(
                _config.Server.Ip,
                _config.Server.Port,
                _config.Server.ReconnectInterval,
                _config.Server.ConnectTimeout
            );

            Logger.Instance.Info("Gateway started successfully");
        }

        /// <summary>
        /// 停止网关
        /// </summary>
        public void Stop()
        {
            if (!_isRunning) return;

            Logger.Instance.Info("Stopping Gateway...");
            _isRunning = false;

            if (_heartbeatTimer != null)
            {
                _heartbeatTimer.Dispose();
                _heartbeatTimer = null;
            }

            _tcp.Disconnect();
            _serial.Close();

            _serialParser.Clear();
            _tcpParser.Clear();

            Logger.Instance.Info("Gateway stopped");
        }

        /// <summary>
        /// 处理来自串口的数据 -> 转发到TCP
        /// </summary>
        private void HandleSerialData(byte[] data)
        {
            if (!_isRunning) return;

            try
            {
                var frames = _serialParser.Parse(data);

                foreach (var frame in frames)
                {
                    // 透传：串口数据直接发送到服务器
                    _tcp.Send(frame);
                }

                // 如果没有解析出完整帧，但有数据，也尝试透传原始数据
                if (frames.Count == 0 && data.Length > 0)
                {
                    // 对于非标准帧，直接透传
                    _tcp.Send(data);
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.Error("Error handling serial data: {0}", ex.Message);
            }
        }

        /// <summary>
        /// 处理来自TCP的数据 -> 转发到串口
        /// </summary>
        private void HandleTcpData(byte[] data)
        {
            if (!_isRunning) return;

            try
            {
                var frames = _tcpParser.Parse(data);

                foreach (var frame in frames)
                {
                    // 透传：TCP数据直接发送到串口
                    _serial.Send(frame);
                }

                // 如果没有解析出完整帧，但有数据，也尝试透传原始数据
                if (frames.Count == 0 && data.Length > 0)
                {
                    _serial.Send(data);
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.Error("Error handling TCP data: {0}", ex.Message);
            }
        }

        /// <summary>
        /// 启动心跳
        /// </summary>
        private void StartHeartbeat()
        {
            if (_heartbeatTimer != null) return;

            _heartbeatTimer = new Timer(o =>
            {
                if (!_isRunning) return;
                // 心跳由下位机发送，中转程序只透传
            }, null, Timeout.Infinite, Timeout.Infinite);
        }

        public void Dispose()
        {
            Stop();
            _serial.Dispose();
            _tcp.Dispose();
        }
    }
}
