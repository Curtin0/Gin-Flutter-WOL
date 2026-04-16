import 'env_config.dart';

/// 数据接口
class API {
  // APP接口BASE_URL - 使用环境配置
  static String get BASE_URL => EnvConfig.config.baseUrl;

  // WebSocket BASE_URL - 使用环境配置
  static String get WS_BASE_URL => EnvConfig.config.wsBaseUrl;

  // 上位机类型对应的Socket端口
  static String get SOCKET_PORT => EnvConfig.config.socketPort;

  // 登录 - APP发给服务器的操作命令
  //---------------------------------------------------------------------上位机类型一
  ///@PMSM10C
  static const record = "/record";
  // 数据查询
  static const query = "/query";
  //---------------------------------------------------------------------上位机类型二
  ///@PMSM04E
  static const record_two = ":20018/record";
  // 数据查询
  static const query_two = ":20018/query";
  //---------------------------------------------------------------------上位机类型三
  ///@PMSM15
  static const record_3 = ":20014/record";
  // 数据查询
  static const query_3 = ":20014/query";
  //---------------------------------------------------------------------上位机类型四
  ///@PMSM10A
  static const record_4 = ":20016/record";
  // 数据查询
  static const query_4 = ":20016/query";

  // 上位机一列表
  static const String online = "/online";
  // 设备在线
  static const String online_inside = "/online_inside";
  // 版本
  static const String version = "/version";
}