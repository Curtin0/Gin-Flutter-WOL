using System;

namespace WinCC.Core
{
    /// <summary>
    /// 运行模式
    /// </summary>
    public enum RunMode
    {
        /// <summary>默认模式</summary>
        Default = 0,
        /// <summary>网关模式：串口转TCP</summary>
        Gateway = 1,
        /// <summary>虚拟风机模式：模拟风机直连TCP服务器</summary>
        VirtualFan = 2
    }

    /// <summary>
    /// 网关配置
    /// </summary>
    public class GatewayConfig
    {
        public RunMode Mode { get; set; } = RunMode.Gateway;
        public ServerConfig Server { get; set; } = new ServerConfig();
        public GatewaySettings Gateway { get; set; } = new GatewaySettings();
        public VirtualFanConfig VirtualFan { get; set; } = new VirtualFanConfig();
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
        public string Ip { get; set; } = "127.0.0.1";
        public int Port { get; set; } = 20019;
        public int ReconnectInterval { get; set; } = 5000;
        public int ConnectTimeout { get; set; } = 10000;
    }

    public class GatewaySettings
    {
        public int Id { get; set; } = 1;
        public int HeartbeatInterval { get; set; } = 15000;
        public SerialConfig Serial { get; set; } = new SerialConfig();
    }

    /// <summary>
    /// 虚拟风机配置
    /// </summary>
    public class VirtualFanConfig
    {
        public bool Enabled { get; set; } = false;
        public int ReportInterval { get; set; } = 5000;
    }

    public class LogConfig
    {
        public string Level { get; set; } = "info";
        public string Path { get; set; } = "./logs/gateway.log";
        public int MaxFiles { get; set; } = 7;
        public long MaxSize { get; set; } = 10485760;
    }
}
