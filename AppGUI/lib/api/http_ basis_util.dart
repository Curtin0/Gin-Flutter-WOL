//import 'dart:io';

import 'package:dio/dio.dart';
import 'apis.dart';
import '../components/common_utils.dart';

class HttpBasisUtil {
  //配置dio，通过BaseOptions
  static Dio _dio = Dio(BaseOptions(
      baseUrl: API.BASE_URL, connectTimeout: 30000, receiveTimeout: 30000));

  /*
   * get请求
   */
  static Future<Response> get(
    url, {
    queryParameters,
    Options options,
    cancelToken,
    String name = "",
    bool showToast = true,
    bool needErrorResponse = false,
  }) async {
    Response response;

    try {
      response = await _dio.get(url,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken);
    } on DioError catch (e) {
      if (CommonUtils.isEmpty(e)) {
        response = Response();
      } else {
        response = e.response;
      }
    }

    if (CommonUtils.isEmpty(response)) {
      return Future.value(Response());
    }
    print("get请求 -- $name response = ${response.data.toString()}");

    return Future.value(response);
  }

  /*
   * post请求
   */
  static Future<Response> post(
    url, {
    data,
    Options options,
    parameter,
    cancelToken,
    String name = "",
    bool showToast = true,
    bool needErrorResponse = false,
  }) async {
    Response response;
    try {
      response = await _dio.post(url,
          data: data,
          queryParameters: parameter,
          options: options,
          cancelToken: cancelToken);
    } on DioError catch (e) {
      response = e.response;
    }

    if (CommonUtils.isEmpty(response)) {
      return Future.value(Response());
    }
    print(
        "post请求 -- $name parameter ：$data response = ${response.data.toString()}");

    return Future.value(response);
  }
}
