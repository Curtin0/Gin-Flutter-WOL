using System;
using System.Net.Sockets;
using System.Threading;
using System.Threading.Tasks;
using WinCC.Utils;
using WinCC.Protocol;

namespace WinCC.Core
{
    public class TcpClientService : IDisposable
    {
        private Socket _socket;
        private readonly object _lock = new object();
        private readonly byte[] _buffer = new byte[4096];
        private CancellationTokenSource _cts;
        private Task _receiveTask;
        private bool _isConnected;
        private bool _isConnecting;

        public event Action<byte[]> OnDataReceived;
        public event Action OnConnected;
        public event Action OnDisconnected;
        public event Action<string> OnError;

        public bool IsConnected => _isConnected;
        public string ServerIp { get; private set; }
        public int ServerPort { get; private set; }

        private int _reconnectInterval = 5000;
        private int _connectTimeout = 10000;

        /// <summary>
        /// 连接到服务器
        /// </summary>
        public void Connect(string ip, int port, int reconnectInterval = 5000, int connectTimeout = 10000)
        {
            ServerIp = ip;
            ServerPort = port;
            _reconnectInterval = reconnectInterval;
            _connectTimeout = connectTimeout;

            _cts = new CancellationTokenSource();

            Task.Run(() => ConnectInternal(_cts.Token));
        }

        private async Task ConnectInternal(CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                try
                {
                    if (_isConnecting)
                    {
                        await Task.Delay(100, ct);
                        continue;
                    }

                    _isConnecting = true;

                    Logger.Instance.Info("Connecting to server {0}:{1}...", ServerIp, ServerPort);

                    var endpoint = new System.Net.IPEndPoint(
                        System.Net.IPAddress.Parse(ServerIp),
                        ServerPort
                    );

                    using (var timeoutCts = new CancellationTokenSource(_connectTimeout))
                    using (var linkedCts = CancellationTokenSource.CreateLinkedTokenSource(ct, timeoutCts.Token))
                    {
                        var socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

                        try
                        {
                            await Task.Run(() => socket.Connect(endpoint), linkedCts.Token);

                            lock (_lock)
                            {
                                _socket = socket;
                                _isConnected = true;
                            }

                            Logger.Instance.Info("Connected to server {0}:{1}", ServerIp, ServerPort);
                            OnConnected?.Invoke();

                            _isConnecting = false;
                            _receiveTask = Task.Run(() => ReceiveLoop(ct));
                            return;
                        }
                        catch
                        {
                            socket.Close();
                            throw;
                        }
                    }
                }
                catch (OperationCanceledException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    _isConnecting = false;
                    Logger.Instance.Warn("Failed to connect to server: {0}", ex.Message);
                    OnError?.Invoke(ex.Message);
                }

                try
                {
                    await Task.Delay(_reconnectInterval, ct);
                }
                catch (OperationCanceledException)
                {
                    break;
                }
            }
        }

        /// <summary>
        /// 断开连接
        /// </summary>
        public void Disconnect()
        {
            lock (_lock)
            {
                if (_socket != null)
                {
                    try
                    {
                        _socket.Close();
                        _socket = null;
                    }
                    catch { }
                }
                _isConnected = false;
            }

            _cts?.Cancel();

            Logger.Instance.Info("Disconnected from server");
            OnDisconnected?.Invoke();
        }

        /// <summary>
        /// 发送数据
        /// </summary>
        public void Send(byte[] data)
        {
            lock (_lock)
            {
                if (!_isConnected || _socket == null)
                {
                    Logger.Instance.Warn("Cannot send data: not connected to server");
                    return;
                }

                if (data == null || data.Length == 0)
                {
                    return;
                }

                try
                {
                    _socket.Send(data);
                    Logger.Instance.Debug("[TCP OUT] {0}", Crc16.ToHexString(data));
                }
                catch (Exception ex)
                {
                    Logger.Instance.Error("Error sending data to server: {0}", ex.Message);
                    HandleDisconnect();
                }
            }
        }

        /// <summary>
        /// 接收数据循环
        /// </summary>
        private async Task ReceiveLoop(CancellationToken ct)
        {
            while (!ct.IsCancellationRequested && _isConnected)
            {
                try
                {
                    int bytesRead = await Task.Run(() =>
                    {
                        if (_socket == null || !_socket.Connected) return 0;
                        return _socket.Receive(_buffer, 0, _buffer.Length, SocketFlags.None);
                    }, ct);

                    if (bytesRead > 0)
                    {
                        byte[] data = new byte[bytesRead];
                        Array.Copy(_buffer, 0, data, 0, bytesRead);

                        Logger.Instance.Debug("[TCP IN] {0}", Crc16.ToHexString(data));

                        OnDataReceived?.Invoke(data);
                    }
                    else
                    {
                        Logger.Instance.Warn("Server closed connection");
                        HandleDisconnect();
                        break;
                    }
                }
                catch (OperationCanceledException)
                {
                    break;
                }
                catch (Exception ex)
                {
                    if (!ct.IsCancellationRequested)
                    {
                        Logger.Instance.Error("Error receiving from server: {0}", ex.Message);
                        HandleDisconnect();
                    }
                    break;
                }
            }
        }

        private void HandleDisconnect()
        {
            lock (_lock)
            {
                if (!_isConnected) return;
                _isConnected = false;
            }

            Logger.Instance.Warn("Lost connection to server, will reconnect...");
            OnDisconnected?.Invoke();

            // 重新连接
            Task.Run(() => ConnectInternal(_cts.Token));
        }

        public void Dispose()
        {
            Disconnect();
            _cts?.Dispose();
        }
    }
}
