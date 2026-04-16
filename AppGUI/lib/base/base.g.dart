// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseResponse _$BaseResponseFromJson(Map<String, dynamic> json) {
  return BaseResponse()
    ..code = (json['code'] as num?)?.toInt()
    ..data = json['data']
    ..data_list = json['data_list']
    ..message = json['message'] as String?
    ..msg = json['msg'] as String?
    ..total = (json['total'] as num?)?.toInt()
    ..sum = (json['sum'] as num?)?.toInt()
    ..resultcode = json['resultcode'] as String?
    ..trackingcode = json['trackingcode'] as String?;
}

Map<String, dynamic> _$BaseResponseToJson(BaseResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'data_list': instance.data_list,
      'message': instance.message,
      'msg': instance.msg,
      'total': instance.total,
      'sum': instance.sum,
      'resultcode': instance.resultcode,
      'trackingcode': instance.trackingcode
    };

CommonResponse _$CommonResponseFromJson(Map<String, dynamic> json) {
  return CommonResponse()
    ..code = (json['code'] as num?)?.toInt()
    ..data = json['data']
    ..message = json['message'] as String?
    ..msg = json['msg'] as String?
    ..sum = (json['sum'] as num?)?.toInt();
}

Map<String, dynamic> _$CommonResponseToJson(CommonResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'data': instance.data,
      'message': instance.message,
      'msg': instance.msg,
      'sum': instance.sum,
    };
