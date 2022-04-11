import 'dart:async';
import '../api/apis.dart';
import '../api/http_util.dart';
//import '../api_net_services/apis.dart';
import '../base/base.dart';
// import '../base/base.dart';
// import '../base/base.dart';
import 'package:flutter_application_4/More/application.dart';

class FanVM {
  // 查询数据
  static Future<BaseResponse> queryFanInfo(
      Map<String, dynamic> parameter) async {
    BaseResponse response = await HttpUtil.post(
        Application.isTypeTwo
            ? API.query_two
            : Application.isType3
                ? API.query_3
                : Application.isType4
                    ? API.query_4
                    : API.query,
        data: parameter,
        name: "查询数据",
        showToast: false);
    return response;
  }

  // 上传数据
  static Future<BaseResponse> recordFan(Map parameter) async {
    BaseResponse response = await HttpUtil.post(
        Application.isTypeTwo
            ? API.record_two
            : Application.isType3
                ? API.record_3
                : Application.isType4
                    ? API.record_4
                    : API.record,
        data: parameter,
        name: "上传数据");
    return response;
  }

  // 上位机
  static Future<BaseResponse> online() async {
    Map parameter = {"socket_client": "all"};
    BaseResponse response =
        await HttpUtil.post(API.online, data: parameter, name: "上位机");
    return response;
  }

  // 设备列表
  static Future<BaseResponse> online_inside(String socket_client) async {
    Map parameter = {"socket_client": socket_client};
    BaseResponse response =
        await HttpUtil.post(API.online_inside, data: parameter, name: "设备列表");
    return response;
  }

  // 版本信息
  static Future<BaseResponse> version() async {
    Map parameter = {"version": "1.1.2"};
    BaseResponse response =
        await HttpUtil.post(API.version, data: parameter, name: "版本信息");
    return response;
  }
}
