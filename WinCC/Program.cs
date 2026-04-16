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

            // 打印配置信息
            Logger.Instance.Info("Configuration:");
            Logger.Instance.Info("  Serial: {0} @ {1}bps", config.Serial.Port, config.Serial.BaudRate);
            Logger.Instance.Info("  Server: {0}:{1}", config.Server.Ip, config.Server.Port);
            Logger.Instance.Info("  Gateway ID: {0}", config.Gateway.Id);

            // 创建并启动网关
            try
            {
                _gateway = new Gateway(config);
                _gateway.Start();
            }
            catch (Exception ex)
            {
                Logger.Instance.Fatal("Failed to start gateway: {0}", ex.Message);
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

            // 验证必要配置
            if (string.IsNullOrEmpty(config.Serial.Port))
            {
                throw new InvalidOperationException("Serial port not configured");
            }

            if (string.IsNullOrEmpty(config.Server.Ip) || config.Server.Port <= 0)
            {
                throw new InvalidOperationException("Server not configured");
            }

            return config;
        }

        private static Utils.LogLevel ParseLogLevel(string level)
        {
            switch (level.ToLower())
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
                    Console.CancelKeyPress += (s, e) =>
                    {
                        e.Cancel = true;
                        evt.Set();
                    };
                    evt.WaitOne();
                }
            }
        }
    }
}
