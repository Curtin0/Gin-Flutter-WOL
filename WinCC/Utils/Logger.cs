using System;
using System.IO;
using System.Text;

namespace WinCC.Utils
{
    public enum LogLevel
    {
        Debug,
        Info,
        Warn,
        Error,
        Fatal
    }

    public class Logger
    {
        private static Logger _instance;
        private static readonly object _lock = new object();

        private readonly string _logPath;
        private readonly long _maxFileSize;
        private readonly int _maxFiles;
        private LogLevel _minLevel;

        private Logger(string logPath, long maxFileSize, int maxFiles, LogLevel minLevel)
        {
            _logPath = logPath;
            _maxFileSize = maxFileSize;
            _maxFiles = maxFiles;
            _minLevel = minLevel;

            var dir = Path.GetDirectoryName(logPath);
            if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }
        }

        public static Logger Instance
        {
            get
            {
                if (_instance == null)
                    throw new InvalidOperationException("Logger not initialized. Call Initialize() first.");
                return _instance;
            }
        }

        public static void Initialize(string logPath, long maxFileSize, int maxFiles, LogLevel minLevel)
        {
            lock (_lock)
            {
                if (_instance == null)
                {
                    _instance = new Logger(logPath, maxFileSize, maxFiles, minLevel);
                }
            }
        }

        public void Debug(string message) => Log(LogLevel.Debug, message);
        public void Info(string message) => Log(LogLevel.Info, message);
        public void Warn(string message) => Log(LogLevel.Warn, message);
        public void Error(string message) => Log(LogLevel.Error, message);
        public void Fatal(string message) => Log(LogLevel.Fatal, message);

        public void Debug(string format, params object[] args) => Log(LogLevel.Debug, string.Format(format, args));
        public void Info(string format, params object[] args) => Log(LogLevel.Info, string.Format(format, args));
        public void Warn(string format, params object[] args) => Log(LogLevel.Warn, string.Format(format, args));
        public void Error(string format, params object[] args) => Log(LogLevel.Error, string.Format(format, args));
        public void Fatal(string format, params object[] args) => Log(LogLevel.Fatal, string.Format(format, args));

        private void Log(LogLevel level, string message)
        {
            if (level < _minLevel) return;

            lock (_lock)
            {
                try
                {
                    RotateLogIfNeeded();

                    var logEntry = string.Format("[{0}] [{1}] {2}", 
                        DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss.fff"), 
                        level.ToString().ToUpper(), 
                        message);

                    File.AppendAllText(_logPath, logEntry + Environment.NewLine, Encoding.UTF8);

                    Console.WriteLine(logEntry);
                }
                catch
                {
                    // Logging should never throw
                }
            }
        }

        private void RotateLogIfNeeded()
        {
            if (!File.Exists(_logPath)) return;

            var fileInfo = new FileInfo(_logPath);
            if (fileInfo.Length < _maxFileSize) return;

            // Rotate files
            for (int i = _maxFiles - 1; i > 0; i--)
            {
                var oldFile = string.Format("{0}.{1}", _logPath, i);
                var newFile = string.Format("{0}.{1}", _logPath, i + 1);
                if (File.Exists(oldFile))
                {
                    if (File.Exists(newFile)) File.Delete(newFile);
                    File.Move(oldFile, newFile);
                }
            }

            var firstBackup = string.Format("{0}.1", _logPath);
            if (File.Exists(firstBackup)) File.Delete(firstBackup);

            File.Move(_logPath, firstBackup);
        }
    }
}
