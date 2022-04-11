import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';

const Color _bgColor = Color(0xCC000000);
const Color _contentColor = Colors.white;
double _textFontSize = 14;
const double _radius = 5.0;
double _imgWH = 24;
const int _time = 1500;
enum _Orientation { horizontal, vertical }

class ToastUtils {
  /// 基础业务提示


  // 加载成功提示
  static Future showSuccess(
      BuildContext context, {
        @required String msg,
        int closeTime = _time,
      }) {
    Widget img = Image.asset("image/hint_successfully.png",width:_imgWH, fit: BoxFit.cover);
    return showImageText(context, msg: msg, image: img,closeTime: closeTime);
  }

  // 加载错误失败提示
  static Future showError(
      BuildContext context, {
        @required String msg,
        int closeTime = _time,
      }) {
    Widget img = Image.asset("image/hint_cancel.png", width: _imgWH,fit: BoxFit.cover);
    return showImageText(context, msg: msg, image: img,closeTime: closeTime);
  }

  // 喜欢收藏提示
  static Future showLikeCollect(
      BuildContext context, {
        @required String msg,
        bool isLikeCollect = true,
        int closeTime = _time,
      }) {
    Widget img = Image.asset(isLikeCollect ? "image/hint_like.png" : "image/hint_nolike.png", width: _imgWH,fit: BoxFit.cover,);
    return showImageText(context, msg: msg, image: img,closeTime: closeTime);
  }

  // 添加曲谱分组提示
  static Future showAdd(
      BuildContext context, {
        @required String msg,
        bool isCircle = true,
        int closeTime = _time,
      }) {
    Widget img = Image.asset(isCircle ? "image/hint_add1.png" : "image/hint_add.png", width: _imgWH,fit: BoxFit.cover);
    return showImageText(context, msg: msg, image: img,closeTime: closeTime);
  }

  /// 通用提示方法
  // 纯文本提示
  static Future showText(
      BuildContext context, {
        @required String msg,
        int closeTime = _time,
      }) {
    return _showToast(
        context: context, msg: msg, stopEvent: true, closeTime: closeTime);
  }

  // 图文提示
  static Future showImageText(
      BuildContext context, {
        @required String msg,
        @required Widget image,
        int closeTime = _time,
      }) {
    return _showToast(
        context: context,
        msg: msg,
        image: image,
        width: 150,
        stopEvent: true,
        closeTime: closeTime);
  }

  // 图文水平提示
  static Future showImageText_horizontal(
      BuildContext context, {
        @required String msg,
        @required Widget image,
        int closeTime = _time,
      }) {
    return _showToast(
        context: context,
        msg: msg,
        image: image,
        stopEvent: true,
        orientation: _Orientation.horizontal,
        closeTime: closeTime);
  }

  // 加载进度提示
  static _HideCallback showLoadingText(
      BuildContext context, {
        String msg = "uploading...",
        VoidCallback tapBackGround,
        int closeTime = 0,
        String closeMsg = "upload time out！",
      }) {
    var hide =  _showJYToast(
        context: context,
        msg: msg,
        isLoading: true,
        stopEvent: true,
        tapBackGround:tapBackGround,
        orientation: _Orientation.vertical);
    if(closeTime > 0) {
      Future.delayed(Duration(milliseconds: closeTime), () {
        hide();
        // showError(context, msg: closeMsg);
      });
    }
    return hide;
  }
  // 加载进度提示
  static _HideCallback showWaitOther(
      BuildContext context, {
        String msg = "loading...",
        VoidCallback tapBackGround,
      }) {
    return _showJYToast(
        context: context,
        msg: msg,
        isLoading: true,
        stopEvent: false,
        tapBackGround:tapBackGround,
        orientation: _Orientation.vertical);
  }

  // 水平加载进度提示
  static _HideCallback showLoadingText_horizontal(
      BuildContext context, {
        String msg = "loading...",
      }) {
    return _showJYToast(
        context: context,
        msg: msg,
        isLoading: true,
        stopEvent: true,
        orientation: _Orientation.horizontal);
  }
}

// 显示Toast
Future _showToast(
    {@required BuildContext context,
      String msg,
      stopEvent = false,
      Widget image,
      int closeTime,
      double width,
      VoidCallback tapBackGround,
      _Orientation orientation = _Orientation.vertical}) {
  msg = msg;
  var hide = _showJYToast(
      context: context,
      msg: msg,
      isLoading: false,
      stopEvent: stopEvent,
      width:width,
      image: image,
      tapBackGround : tapBackGround,
      orientation: orientation);
  return Future.delayed(Duration(milliseconds: closeTime), () {
    hide();
  });
}

typedef _HideCallback = Future Function();

int backButtonIndex = 2;

// 隐藏Toast
_HideCallback _showJYToast({
  @required BuildContext context,
  @required String msg,
  Widget image,
  double width,
  @required bool isLoading,
  bool stopEvent = false,
  VoidCallback tapBackGround,
  _Orientation orientation = _Orientation.vertical,
}) {
  Completer<VoidCallback> result = Completer<VoidCallback>();
  var backButtonName = 'JYToast$backButtonIndex';
  BackButtonInterceptor.add((stopDefaultButtonEvent,routeInfo) {
    result.future.then((hide) {
      hide();
    });
    return true;
  }, zIndex: backButtonIndex, name: backButtonName);
  backButtonIndex++;
  final size =MediaQuery.of(context).size;
  final screenWidth = size.width;
  final screenHeight = size.height;

  var overlay = OverlayEntry(
      maintainState: true,
      builder: (_) => WillPopScope(
        onWillPop: () async {
          var hide = await result.future;
          hide();
          return false;
        },
        child: GestureDetector(
          onTap: tapBackGround,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: screenWidth,
            height: screenHeight,
            color: Colors.transparent,
            child: JYToastWidget(
              image: image,
              msg: msg,
              width: width,
              stopEvent: stopEvent,
              isLoading: isLoading,
              orientation: orientation,
            ),
          ),
        ),
      ));
  result.complete(() {
    if (overlay == null) {
      return;
    }
    overlay.remove();
    overlay = null;
    BackButtonInterceptor.removeByName(backButtonName);
  });
  Overlay.of(context).insert(overlay);
  return () async {
    var hide = await result.future;
    hide();
  };
}

// 自定义Toast Widget
class JYToastWidget extends StatelessWidget {
  const JYToastWidget({
    Key key,
    @required this.msg,
    this.image,
    this.width,
    @required this.isLoading,
    @required this.stopEvent,
    @required this.orientation,
  }) : super(key: key);

  final bool stopEvent;
  final Widget image;
  final String msg;
  final bool isLoading;
  final double width;
  final _Orientation orientation;

  @override
  Widget build(BuildContext context) {
    Widget topW;
    bool isHidden;
    if (this.isLoading == true) {
      isHidden = false;
      topW = CircularProgressIndicator(
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation<Color>(_contentColor),
      );
    } else {
      isHidden = image == null ? true : false;
      topW = image;
    }

    var widget = Material(
        color: Colors.transparent,
        child: Align(
            alignment: Alignment(0.0, -0.2), //中间往上一点
            child: Container(
//              width: width,
              constraints:BoxConstraints(minWidth: width == null ? 150 : width),
              margin:  EdgeInsets.all(50),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(_radius),
              ),
              child: ClipRect(
                child: orientation == _Orientation.vertical
                    ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Offstage(
                      offstage: isHidden,
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(4),
                        child: topW,
                      ),
                    ),
                    Text(msg,
                      style: TextStyle(
                          fontSize: _textFontSize,
                          color: _contentColor),
                      textAlign: TextAlign.center,),
                  ],
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Offstage(
                      offstage: isHidden,
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: EdgeInsets.only(right: 8),
                        padding: EdgeInsets.all(4),
                        child: topW,
                      ),
                    ),
                    Text(msg,
                        style: TextStyle(
                            fontSize: _textFontSize,
                            color: _contentColor),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            )));
    return AbsorbPointer(
      absorbing: !stopEvent,
      child: widget,
    );
  }
}
