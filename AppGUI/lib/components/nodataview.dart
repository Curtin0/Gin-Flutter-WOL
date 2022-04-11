import 'package:flutter/material.dart';
import 'package:flutter_application_4/components/common_utils.dart';

class NoDataView extends StatefulWidget {
  String imageStr;
  String text;
  TextStyle textStyle;
  String subText;
  double height;
  double imageHeight;
  TextStyle subTextStyle;
  String actionTitle;
  Color backgroundColor;
  EdgeInsets padding;

  final VoidCallback emptyRetry; //无数据事件处理
  NoDataView(this.imageStr, this.text,
      {this.textStyle,
        this.subText,
        this.subTextStyle,
        this.actionTitle,
        this.padding,
        this.emptyRetry,
        this.height,
        this.imageHeight
      });

  @override
  _NoDataViewState createState() => _NoDataViewState();
}

class _NoDataViewState extends State<NoDataView> {
  @override
  Widget build(BuildContext context) {
    widget.padding = widget.padding ?? EdgeInsets.zero;
    return
      Center(
        child: Container(
            height: widget.height,
            padding:widget.padding,
            alignment: Alignment.center,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                if (!CommonUtils.isEmpty(widget.imageStr)) (
                          Container(
                            width: 360,
                            height: widget.imageHeight ?? 280,
                            child: Image.asset(widget.imageStr,fit: BoxFit.contain,),
                          )
                      ),
                        Text(CommonUtils.safeStr(widget.text),
                            style: widget.textStyle != null ? widget.textStyle : TextStyle(
                                color:Colors.grey,
                                   fontSize: 14, height: 1.5)),
                        Text(CommonUtils.safeStr(widget.subText),
                            style: widget.subTextStyle != null ? widget.subTextStyle : TextStyle(
                                color:Colors.grey,
                                fontSize: 14, height: 1.5)),
                ],
            )
        ),
      );

  }
}

