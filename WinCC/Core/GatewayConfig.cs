using System;

namespace WinCC.Core
{
    /// <summary>
    /// 网关配置
    /// </summary>
    public class GatewayConfig
    {
        public SerialConfig Serial { get; set; } = new SerialConfig();
        public ServerConfig Server { get; set; } = new ServerConfig();
        public GatewaySettings Gateway { get; set; } = new GatewaySettings();
        public LogConfig Log { get; set; } = new LogConfig();
    }

    public class SerialConfig
    {
        public string Port { get; set; } = "COM3";
        public int BaudRate { get; set; } = 19200;
        public int DataBits { get; set; } = 8;
        public int StopBits { get; set; } = 1;
        public int Parity { get; set; } = 0;
        public int ReadTimeout { get; set; } = 3000;
        public int WriteTimeout { get; set; } = 3000;
    }

    public class ServerConfig
    {
        public string Ip { get; set; } = "112.74.182.249";
        public int Port { get; set; } = 20019;
        public int ReconnectInterval { get; set; } = 5000;
        public int ConnectTimeout { get; set; } = 10000;
    }

    public class GatewaySettings
    {
        public int Id { get; set; } = 1;
        public int HeartbeatInterval { get; set; } = 15000;
    }

    public class LogConfig
    {
        public string Level { get; set; } = "info";
        public string Path { get; set; } = "./logs/gateway.log";
        public int MaxFiles { get; set; } = 7;
        public long MaxSize { get; set; } = 10485760;
    }
}
