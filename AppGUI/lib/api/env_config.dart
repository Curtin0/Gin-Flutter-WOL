/// 环境配置
class EnvConfig {
  // 当前环境: dev | prod
  static const String env = 'prod';

  // 开发环境配置
  static const dev = _Env(
    baseUrl: 'http://localhost:8080',
    wsBaseUrl: 'ws://localhost:8080',
    socketPort: ':20018', // 不同类型设备使用不同端口
  );

  // 生产环境配置
  static const prod = _Env(
    baseUrl: 'http://112.74.182.249',
    wsBaseUrl: 'ws://112.74.182.249',
    socketPort: '', // 使用默认端口
  );

  static _Env get config {
    return env == 'dev' ? dev : prod;
  }
}

class _Env {
  final String baseUrl;
  final String wsBaseUrl;
  final String socketPort;

  const _Env({
    required this.baseUrl,
    required this.wsBaseUrl,
    required this.socketPort,
  });
}
