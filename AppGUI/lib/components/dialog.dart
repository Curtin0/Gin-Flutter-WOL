import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T> _showAlert<T>({BuildContext context, Widget child}) => showDialog<T>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => child,
    );
    
Future<bool> showAlert(BuildContext context, {String title, String negativeText = "取消", String positiveText = "确定", bool onlyPositive = false}) =>
    _showAlert<bool>(
      context: context,
      child: CupertinoAlertDialog(
        content: Container(
          margin: EdgeInsets.only(top: 20,left:20,right: 20,bottom: 20,),
          child: Text(title,style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
        ),
        actions: _buildAlertActions(context, onlyPositive, negativeText, positiveText),
      ),
    );

List<Widget> _buildAlertActions(BuildContext context, bool onlyPositive, String negativeText, String positiveText) {
  if (onlyPositive) {
    return [
      CupertinoDialogAction(
        child: Text(
          positiveText,
          style: TextStyle(fontSize: 14),
        ),
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context, true);
        },
      ),
    ];
  } else {
    return [
      CupertinoDialogAction(
        child: Text(
          negativeText,
        ),
        isDestructiveAction: true,
        onPressed: () {
          Navigator.pop(context, false);
        },
      ),
      CupertinoDialogAction(
        child: Text(
          positiveText,
          style: TextStyle(fontSize: 14),
        ),
        isDefaultAction: true,
        onPressed: () {
          Navigator.pop(context, true);
        },
      ),
    ];
  }
}


///  显示loading框  , 隐藏调用 Navigator.pop(context)
Future _showLoadingDialog(BuildContext c, LoadingDialog loading, {bool cancelable = true}) =>
    showDialog(context: c, barrierDismissible: cancelable, builder: (BuildContext c) => loading);

class LoadingDialog extends CupertinoAlertDialog {
  BuildContext currentContext;

  show(BuildContext context) {
    showing = true;
    _showLoadingDialog(context, this).then((r) {
      showing = false;
    });
  }

  bool showing;

  hide(BuildContext context) {
    if (showing) {
      Navigator.removeRoute(context, ModalRoute.of(currentContext));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    currentContext = context;
    return WillPopScope(
      onWillPop: () => Future.value(!bool.fromEnvironment("dart.vm.product")),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: Container(
              width: 120,
              height: 120,
              color: Colors.transparent,
              child: const Center(
                child: SizedBox(
                    width: 45.0,
                    height: 45.0,
                    child: const CircularProgressIndicator(strokeWidth: 2.0)
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
