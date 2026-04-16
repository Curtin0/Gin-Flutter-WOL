// 使用单例模式(只被实例化一次)
import 'package:dio/dio.dart';
import '../base/base.dart';
import '../components/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'apis.dart';

class HttpUtil {
  static HttpUtil? _instance;
  static late Dio _dio;
  late BaseOptions _options;
  CancelToken cancelToken = CancelToken();

  /// 是否开发环境
  static const bool isDev = !const bool.fromEnvironment("dart.vm.product");

  //判断是否重新实例
  static HttpUtil getInstance() {
    _instance ??= HttpUtil._();
    return _instance!;
  }

  HttpUtil._() {
    _options = BaseOptions(
        baseUrl: API.BASE_URL, connectTimeout: 30000, receiveTimeout: 30000);
    _dio = Dio(_options)
      ..interceptors.add(InterceptorsWrapper(onRequest:
          (RequestOptions options, RequestInterceptorHandler handler) {
        Map<String, dynamic> headerMap = {};
        if (!CommonUtils.isEmpty(options.headers["token"])) {
          headerMap.putIfAbsent(
              'Authorization', () => options.headers["token"]);
        }
        options.headers.addAll(headerMap);
        handler.next(options);
      }, onResponse: (Response response, ResponseInterceptorHandler handler) {
        print(
            "====== 网络请求 - ${CommonUtils.safeStr(response.requestOptions.extra["name"])} ======  \n "
            "*** Request *** \n "
            "${response.requestOptions.method} ${response.requestOptions.uri} \n "
            "header ${response.requestOptions.headers} \n "
            "data ${response.requestOptions.data} \n "
            "queryParameters ${response.requestOptions.queryParameters} \n "
            "*** Response *** \n "
            "${CommonUtils.convert(response.data)} \n ");
        if (response.data["code"] != null && response.data["code"] != '0') {
          if (CommonUtils.safeStr(
              response.requestOptions.extra["showToastFlg"], true)) {
            showToast(response);
          }
        }
        handler.next(response);
      }, onError: (DioError e, ErrorInterceptorHandler handler) {
        print(
            "====== 网络请求 - 错误 - ${CommonUtils.safeStr(e.requestOptions.extra["name"])} ======  \n "
            "*** Request *** \n "
            "${e.requestOptions.method} ${e.requestOptions.uri} \n "
            "header ${e.requestOptions.headers} \n "
            "data ${e.requestOptions.data} \n "
            "queryParameters ${e.requestOptions.queryParameters} \n "
            "*** Response *** \n "
            "${CommonUtils.safeStr(e.response?.data)} \n");
        handler.next(e);
      }));
  }

  Dio get dio => _dio;

  static Dio get dioInstance => _dio;

  /*
   * get请求
   */
  static Future<BaseResponse> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    String? name,
    BuildContext? showLoadingContext,
    bool showToast = true,
    bool needErrorResponse = true,
    bool isJson = true,
  }) async {
    Response? response;
    loadingDialog(showLoadingContext);
    if (options == null) {
      options = Options(extra: {
        "name": CommonUtils.safeStr(name),
        "showToastFlg": showToast
      });
    } else {
      options.extra ??= {};
      if (!options.extra!.containsKey("name")) {
        options.extra!.putIfAbsent("name", () => CommonUtils.safeStr(name));
        options.extra!.putIfAbsent("showToastFlg", () => showToast);
      }
    }
    if (!isJson) {
      options.contentType = 'application/x-www-form-urlencoded';
    }

    try {
      response = await _dio.get(url,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken);
    } on DioError catch (e) {
      loadingDialog(showLoadingContext, hidden: true);
      if (showToast) {
        formatError(e);
      }
      if (needErrorResponse) {
        response = e.response;
      }
    }
    loadingDialog(showLoadingContext, hidden: true);
    var res = CommonUtils.isEmpty(response)
        ? BaseResponse()
        : BaseResponse.fromJson(response!.data);
    return res;
  }

  /*
   * post请求
   */
  static Future<BaseResponse> post(
    String url, {
    dynamic data,
    Options? options,
    Map<String, dynamic>? parameter,
    CancelToken? cancelToken,
    String? name,
    BuildContext? showLoadingContext,
    bool showToast = true,
    bool needErrorResponse = true,
    bool isJson = true,
  }) async {
    Response? response;
    loadingDialog(showLoadingContext);
    if (options == null) {
      options = Options(extra: {
        "name": CommonUtils.safeStr(name),
        "showToastFlg": showToast
      });
    } else {
      options.extra ??= {};
      if (!options.extra!.containsKey("name")) {
        options.extra!.putIfAbsent("name", () => CommonUtils.safeStr(name));
        options.extra!.putIfAbsent("showToastFlg", () => showToast);
      }
    }
    if (!isJson) {
      print("表单");
      options.contentType = 'multipart/form-data';
    }
    try {
      response = await _dio.post(url,
          data: data,
          queryParameters: parameter,
          options: options,
          cancelToken: cancelToken);
    } on DioError catch (e) {
      loadingDialog(showLoadingContext, hidden: true);
      if (showToast) {
        formatError(e);
      }
      if (needErrorResponse) {
        response = e.response;
      }
    }

    loadingDialog(showLoadingContext, hidden: true);
    var res = CommonUtils.isEmpty(response)
        ? BaseResponse()
        : BaseResponse.fromJson(response!.data);
    return res;
  }

  static Future<dynamic> postRequest(String url, dynamic body,
      {Map<String, dynamic>? queryParameters,
      String? contentType,
      Map<String, dynamic>? headers}) async {
    Response? response;
    try {
      response = await _dio.post(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(
            contentType: contentType,
            headers: headers == null ? headers : Map.from(headers)),
      );
    } on DioError catch (e) {
      formatError(e);
    }
    return response?.data;
  }

  // loading
  static loadingDialog(BuildContext? showLoadingContext,
      {bool hidden = false}) {
    if (showLoadingContext != null) {
      if (hidden == true) {
        print("LoadingDialogHidden");
      } else {
        print("LoadingDialogShow");
      }
    }
  }

  /*
   * error统一处理
   */
  static void formatError(DioError e) {
    print("网络错误 - ${e.type} - ${e.message}");

    if (e.response != null &&
        e.response!.data != null &&
        (e.response!.data["code"] == 2)) {
      print("登录失效");
      reLogin();
    }

    showToast(e.response);
  }

  /*
   * 提示
   */
  static void showToast(Response? response) {
    Fluttertoast.showToast(
        msg: response != null
            ? response.data["msg"] ??
                "服务器异常，code：" + response.statusCode.toString()
            : "网络请求异常！",
        gravity: ToastGravity.CENTER);
  }

  /*
   * 登录失效 重新登录
   */
  static void reLogin() async {
    // bool success = await UserManager.logout();
    // if(success){
    //   SystemChrome.setPreferredOrientations([
    //     DeviceOrientation.landscapeLeft,
    //     DeviceOrientation.landscapeRight,
    //   ]);
    //   // NavigationManager.pushNamed(Routes.home, arguments: {"showLogin": true});
    // }
  }

  /*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
  void cancelRequests(CancelToken token) {
    token.cancel("cancelled");
  }
}
