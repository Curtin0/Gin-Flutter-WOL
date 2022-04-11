import 'package:json_annotation/json_annotation.dart';
import 'package:dio/dio.dart';

part 'base.g.dart';

@JsonSerializable()
class BaseResponse<T> extends Response {
  int code;
  dynamic data;
  dynamic data_list;

  String message;
  String msg;
  bool get success => code == 0;
  int total;
  int sum;
  String resultcode;
  String trackingcode;

  BaseResponse();

  factory BaseResponse.fromJson(Map<String, dynamic> json) =>
      _$BaseResponseFromJson(json);

  static Map<String, dynamic> toJson(BaseResponse instance) =>
      _$BaseResponseToJson(instance);
}

@JsonSerializable()
class CommonResponse {
  int code;
  dynamic data;
  String message;
  String msg;
  int sum;

  CommonResponse();

  factory CommonResponse.fromJson(Map<String, dynamic> json) =>
      _$CommonResponseFromJson(json);

  static Map<String, dynamic> toJson(CommonResponse instance) =>
      _$CommonResponseToJson(instance);
}
