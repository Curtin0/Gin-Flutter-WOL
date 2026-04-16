import 'package:flutter/material.dart';
import 'package:flutter_application_4/components/common_utils.dart';

class NoDataView extends StatefulWidget {
  final String imageStr;
  final String text;
  final TextStyle? textStyle;
  final String? subText;
  final double? height;
  final double? imageHeight;
  final TextStyle? subTextStyle;
  final String? actionTitle;
  final Color backgroundColor;
  final EdgeInsets? padding;

  final VoidCallback? emptyRetry; //无数据事件处理
  NoDataView(this.imageStr, this.text,
      {this.textStyle,
      this.subText,
      this.subTextStyle,
      this.actionTitle,
      this.backgroundColor = Colors.transparent,
      this.padding,
      this.emptyRetry,
      this.height,
      this.imageHeight});

  @override
  _NoDataViewState createState() => _NoDataViewState();
}

class _NoDataViewState extends State<NoDataView> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: widget.height,
          padding: widget.padding,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (!CommonUtils.isEmpty(widget.imageStr))
                (Container(
                  width: 360,
                  height: widget.imageHeight ?? 280,
                  child: Image.asset(
                    widget.imageStr,
                    fit: BoxFit.contain,
                  ),
                )),
              Text(CommonUtils.safeStr(widget.text),
                  style: widget.textStyle ??
                      TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
              Text(CommonUtils.safeStr(widget.subText),
                  style: widget.subTextStyle ??
                      TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
            ],
          )),
    );
  }
}
