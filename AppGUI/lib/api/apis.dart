/// 数据接口
class API {
  // APP接口BASE_URL
  static const BASE_URL = "http://112.74.182.249";

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
