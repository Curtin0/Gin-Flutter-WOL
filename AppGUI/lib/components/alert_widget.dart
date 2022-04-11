import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertTools {

  static void showCupertinoAlert(BuildContext context,String title, String content, List actions,Function(int index) click) {
    showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: actions.asMap().keys.map((e) => CupertinoDialogAction(
              child: Text(actions[e]),
              onPressed: () {
                click(e);
                Navigator.of(context).pop();
              },
            )).toList()
        ));
  }
}

class ShowCupertinoAlertDialogWidget extends StatelessWidget {
  String title;
  String content;
  List actions;

  ShowCupertinoAlertDialogWidget(this.title,this.content,this.actions);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: title,
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text(title),
        ),
        body: Builder(builder: (context) {
          return RaisedButton(
            onPressed: () {

            },
            child: Text('showDialog'),
          );
        }),
      ),
    );
  }
}