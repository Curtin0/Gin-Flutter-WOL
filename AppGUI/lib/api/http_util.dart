// 使用单例模式(只被实例化一次)
import 'package:dio/dio.dart';
import '../base/base.dart';
//import '../components/jytoast.dart';
import '../components/common_utils.dart';
import 'package:flutter/cupertino.dart';
//import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'apis.dart';

class HttpUtil {
  static HttpUtil instance;
  static Dio dio;
  BaseOptions options;
  CancelToken cancelToken = new CancelToken();

  /// 是否开发环境
  static const bool isDev = !const bool.fromEnvironment("dart.vm.product");
//判断是否重新实例

  static HttpUtil getInstance() {
    if (null == instance) instance = new HttpUtil();
    return instance;
  }
/*
   * 构造函数（初始化配置）
   */

  HttpUtil() {
    //BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
    dio = new Dio()
      ..options = BaseOptions(
          //请求基地址,可以包含子路径
          baseUrl: API.BASE_URL,
          //连接服务器超时时间，单位是毫秒.
          connectTimeout: 30000,
          //响应流上前后两次接受到数据的间隔，单位为毫秒。
          receiveTimeout: 30000)
      ..interceptors
          .add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        Map<String, dynamic> headerMap = Map<String, dynamic>();
        if (!CommonUtils.isEmpty(options.headers["token"])) {
          headerMap.putIfAbsent(
              'Authorization', () => options.headers["token"]);
        } else {
          // final token = UserManager.getUserToken();
          // if (!CommonUtils.isEmpty(token)) {
          //   headerMap.putIfAbsent('Authorization', () => token);
          // }
        }

        options.headers.addAll(headerMap);
        return options;
      }, onResponse: (Response response) {
//        LogUtil.d("完整的response ====== $response");
        // if(isDev){
        print(
            "====== 网络请求 - ${CommonUtils.safeStr(response.request.extra["name"])} ======  \n "
            "*** Request *** \n "
            "${response.request.method} ${response.request.uri} \n "
            "header ${response.request.headers} \n "
            "data ${response.request.data} \n "
            "queryParameters ${response.request.queryParameters} \n "
            "*** Response *** \n "
            "${CommonUtils.convert(response.data)} \n ");
        // }
        if (response.data["code"] != null && response.data["code"] != '0') {
          // print("showToastFlg === response ${response.request.extra["showToastFlg"]} ~~~~ ${response.request.uri} ~~~ ${CommonUtils.safeStr(response.request.extra["name"])}");

          // 提示
          if (CommonUtils.safeStr(
              response.request.extra["showToastFlg"], true)) {
            showToast(response);
          }
        }
//        rsaTest();
        return response; // continue
      }, onError: (DioError e) {
        // if(isDev){
        print(
            "====== 网络请求 - 错误 - ${CommonUtils.safeStr(e.request.extra["name"])} ======  \n "
            "*** Request *** \n "
            "${e.request.method} ${e.request.uri} \n "
            "header ${e.request.headers} \n "
            "data ${e.request.data} \n "
            "queryParameters ${e.request.queryParameters} \n "
            "*** Response *** \n "
            "${CommonUtils.safeStr(e.response?.data)} \n");
        // }
        return e; //continue
      }));
  }

  /*
   * get请求
   */
  static Future<BaseResponse> get(
    url, {
    queryParameters,
    Options options,
    cancelToken,
    String name,
    BuildContext showLoadingContext,
    bool showToast = true,
    bool needErrorResponse = true,
    bool isJson = true,
  }) async {
    Response response;
    // 根据是否存在showLoadingContext 动态加载loading
    loadingDialog(showLoadingContext);
    // 设置请求名称,方便打印日志,比如登录接口 - name = 登录 -
    if (options == null) {
      options = Options(extra: {
        "name": CommonUtils.safeStr(name),
        "showToastFlg": showToast
      });
    } else if (!options.extra.containsKey("name")) {
      options.extra.putIfAbsent("name", () => CommonUtils.safeStr(name));
      options.extra.putIfAbsent("showToastFlg", () => showToast);
    }
    if (!isJson) {
      options.contentType = 'application/x-www-form-urlencoded';
    }

    try {
      response = await dio.get(url,
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
        : BaseResponse.fromJson(response.data);
    return Future.value(res);
  }

  /*
   * post请求
   */
  static Future<BaseResponse> post(
    url, {
    data,
    Options options,
    parameter,
    cancelToken,
    String name,
    BuildContext showLoadingContext,
    bool showToast = true,
    bool needErrorResponse = true,
    bool isJson = true,
  }) async {
    Response response;
    // 根据是否存在showLoadingContext 动态加载loading
    loadingDialog(showLoadingContext);
    // 设置请求名称,方便打印日志,比如登录接口 - name = 登录 -
    if (options == null) {
      options = Options(extra: {
        "name": CommonUtils.safeStr(name),
        "showToastFlg": showToast
      });
    } else if (!options.extra.containsKey("name")) {
      options.extra.putIfAbsent("name", () => CommonUtils.safeStr(name));
      options.extra.putIfAbsent("showToastFlg", () => showToast);
    }
    if (!isJson) {
      print("表单");
      options.contentType = 'multipart/form-data';
    }
    try {
      response = await dio.post(url,
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
        : BaseResponse.fromJson(response.data);
    return Future.value(res);
  }

  static Future<Map<dynamic, dynamic>> postRequest(String url, dynamic body,
      {Map<String, dynamic> queryParameters,
      String contentType,
      Map headers}) async {
    var response;
    try {
      response = await HttpUtil.dio.post(
        url,
        data: body,
        queryParameters: queryParameters,
        options: Options(
            contentType: contentType,
            headers: headers == null ? headers : Map.from(headers)),
      );
    } on DioError catch (e) {
      HttpUtil.formatError(e);
    }
    return response.data;
    // var res = BaseResponse.fromJson(response.data);
    // return Future.value(res);
  }

  // loading
  static loadingDialog(BuildContext showLoadingContext, {bool hidden = false}) {
    if (showLoadingContext != null) {
      if (hidden == true) {
        print("LoadingDialogHidden");
        // LoadingAnimation.hideLoading(showLoadingContext);
      } else {
        print("LoadingDialogShow");
        // LoadingAnimation.showLoading(showLoadingContext);
      }
    }
  }

  /*
   * error统一处理
   */
  static void formatError(DioError e) {
    // if(Application.rootContext != null) {
    //   loadingDialog(Application.rootContext, hidden: true);
    // }
    if (e.type == DioErrorType.CONNECT_TIMEOUT) {
      print("连接超时 - ${e}");
    } else if (e.type == DioErrorType.SEND_TIMEOUT) {
      print("请求超时 - ${e}");
    } else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
      print("响应超时 - ${e}");
    } else if (e.type == DioErrorType.RESPONSE) {
      print("出现异常404 503 - ${e}");
    } else if (e.type == DioErrorType.CANCEL) {
      print("请求取消 - ${e}");
    } else {
      print("未知错误 - ${e}");
    }

    if (e.response != null &&
        e.response.data != null &&
        (e.response.data["code"] == 2)) {
      print("登录失效");
      reLogin();
    }

    // 提示
    showToast(e.response);
  }

  /*
   * 提示
   */
  static void showToast(Response response) {
    // if(Application.rootContext != null) {
    //   ToastUtils.showError(Application.rootContext,
    //       msg:response != null ? response.data["msg"] ??
    //           "服务器异常，code：" + response.statusCode.toString() : "网络请求异常！",closeTime: 1800);
    // }else {
    Fluttertoast.showToast(
        msg: response != null
            ? response.data["msg"] ??
                "服务器异常，code：" + response.statusCode.toString()
            : "网络请求异常！",
        gravity: ToastGravity.CENTER);
    // }
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
