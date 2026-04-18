using System;
using System.IO;
using System.Threading;
using WinCC.Utils;
using WinCC.Core;

namespace WinCC
{
    internal class Program
    {
        private static Gateway _gateway;
        private static VirtualFan.VirtualFanDevice _virtualFan;
        private static bool _isShuttingDown;

        static void Main(string[] args)
        {
            // 解析命令行参数
            string configPath = "config.json";
            for (int i = 0; i < args.Length; i++)
            {
                if (args[i] == "-c" && i + 1 < args.Length)
                {
                    configPath = args[i + 1];
                }
            }

            // 加载配置
            GatewayConfig config;
            try
            {
                config = LoadConfig(configPath);
                Console.WriteLine("Loaded config from: {0}", configPath);
            }
            catch (Exception ex)
            {
                Console.WriteLine("Failed to load config: {0}", ex.Message);
                Console.WriteLine("Press any key to exit...");
                Console.ReadKey();
                return;
            }

            // 初始化日志
            var logLevel = ParseLogLevel(config.Log.Level);
            Logger.Initialize(config.Log.Path, config.Log.MaxSize, config.Log.MaxFiles, logLevel);

            Logger.Instance.Info("===========================================");
            Logger.Instance.Info("WinCC Gateway v1.0.0 - PMSM Fan Data Gateway");
            Logger.Instance.Info("===========================================");

            // 解析运行模式 - 优先检查 VirtualFan.Enabled
            RunMode runMode;
            string modeStr;
            if (config.VirtualFan != null && config.VirtualFan.Enabled)
            {
                runMode = RunMode.VirtualFan;
                modeStr = "virtual_fan";
            }
            else
            {
                runMode = RunMode.Gateway;
                modeStr = "gateway";
            }

            Logger.Instance.Info("Run Mode: {0}", modeStr);
            Logger.Instance.Info("Configuration:");
            Logger.Instance.Info("  Server: {0}:{1}", config.Server.Ip, config.Server.Port);
            Logger.Instance.Info("  Gateway ID: {0}", config.Gateway.Id);

            // 根据模式启动
            try
            {
                if (runMode == RunMode.VirtualFan)
                {
                    // 虚拟风机模式
                    Logger.Instance.Info("Starting Virtual Fan mode...");
                    Logger.Instance.Info("  Report Interval: {0}ms", config.VirtualFan.ReportInterval);
                    _virtualFan = new VirtualFan.VirtualFanDevice(config);
                    _virtualFan.Start();
                }
                else
                {
                    // 网关模式
                    Logger.Instance.Info("Starting Gateway mode...");
                    Logger.Instance.Info("  Serial: {0} @ {1}bps", config.Gateway.Serial.Port, config.Gateway.Serial.BaudRate);
                    _gateway = new Gateway(config);
                    _gateway.Start();
                }
            }
            catch (Exception ex)
            {
                Logger.Instance.Fatal("Failed to start: {0}", ex.Message);
                Console.WriteLine("Press any key to exit...");
                Console.ReadKey();
                return;
            }

            // 注册关闭事件
            Console.CancelKeyPress += OnCancelKeyPress;

            // 等待关闭信号
            WaitForShutdown();

            // 清理
            _gateway?.Dispose();
            _virtualFan?.Stop();
            Logger.Instance.Info("Gateway exited");
        }

        private static GatewayConfig LoadConfig(string path)
        {
            if (!File.Exists(path))
            {
                throw new FileNotFoundException(string.Format("Config file not found: {0}", path));
            }

            string json = File.ReadAllText(path);
            var config = Newtonsoft.Json.JsonConvert.DeserializeObject<GatewayConfig>(json);

            if (config == null)
            {
                throw new InvalidOperationException("Failed to parse config file");
            }

            // 兼容旧配置文件 - 如果没有 VirtualFan 节点，创建默认
            if (config.VirtualFan == null)
            {
                config.VirtualFan = new VirtualFanConfig { Enabled = false, ReportInterval = 5000 };
            }

            // 兼容旧配置文件 - 如果没有 Mode 节点，根据 VirtualFan.Enabled 判断
            if (config.Mode == RunMode.Default)
            {
                if (config.VirtualFan != null && config.VirtualFan.Enabled)
                {
                    config.Mode = RunMode.VirtualFan;
                }
                else
                {
                    config.Mode = RunMode.Gateway;
                }
            }

            // 确保 Gateway.Serial 存在
            if (config.Gateway.Serial == null)
            {
                config.Gateway.Serial = new SerialConfig();
            }

            // 验证必要配置 (网关模式需要串口)
            if (config.Mode == RunMode.Gateway)
            {
                if (string.IsNullOrEmpty(config.Gateway.Serial.Port))
                {
                    throw new InvalidOperationException("Serial port not configured");
                }
            }

            if (string.IsNullOrEmpty(config.Server.Ip) || config.Server.Port <= 0)
            {
                throw new InvalidOperationException("Server not configured");
            }

            return config;
        }

        private static Utils.LogLevel ParseLogLevel(string level)
        {
            switch (level?.ToLower())
            {
                case "debug": return Utils.LogLevel.Debug;
                case "info": return Utils.LogLevel.Info;
                case "warn": return Utils.LogLevel.Warn;
                case "error": return Utils.LogLevel.Error;
                case "fatal": return Utils.LogLevel.Fatal;
                default: return Utils.LogLevel.Info;
            }
        }

        private static void OnCancelKeyPress(object sender, ConsoleCancelEventArgs e)
        {
            if (_isShuttingDown) return;
            _isShuttingDown = true;

            Console.WriteLine();
            Logger.Instance.Info("Received shutdown signal (Ctrl+C)...");

            e.Cancel = true; // 阻止进程立即退出

            // 在另一个线程中执行关闭
            ThreadPool.QueueUserWorkItem(_ =>
            {
                _gateway?.Dispose();
                _virtualFan?.Stop();
                Environment.Exit(0);
            });
        }

        private static void WaitForShutdown()
        {
            if (!Environment.UserInteractive)
            {
                // 服务模式 - 阻止主线程退出
                using (var evt = new ManualResetEvent(false))
                {
                    evt.WaitOne();
                }
            }
            else
            {
                // 控制台模式
                Console.WriteLine("Press Ctrl+C to stop the gateway...");
                Console.WriteLine();
                using (var evt = new ManualResetEvent(false))
                {
                    Console.CancelKeyPress += (s, ev) =>
                    {
                        ev.Cancel = true;
                        evt.Set();
                    };
                    evt.WaitOne();
                }
            }
        }
    }
}
