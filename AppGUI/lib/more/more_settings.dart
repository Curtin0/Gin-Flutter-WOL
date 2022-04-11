import 'package:flutter/material.dart';

class MoreSettings extends StatefulWidget {
  MoreSettings({Key key, @required this.mt}) : super(key: key);

  final String mt;

  @override
  _MoreSettingsState createState() {
    return new _MoreSettingsState();
  }
}

class _MoreSettingsState extends State<MoreSettings> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'More',
      home: Scaffold(
        body: Center(
          child: ListView(
            padding: EdgeInsets.all(10), //外边距
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.brightness_5, color: Colors.grey, size: 20),
                title: Text('版本号 1.0.0', style: TextStyle()),
              ),
              Divider(
                color: Colors.grey,
              ),
              ListTile(
                leading: Icon(Icons.android, color: Colors.grey, size: 20),
                title: Text('适用系统 Android 11 / Windows 10', style: TextStyle()),
              ),
              Divider(
                color: Colors.grey,
              ),
              ListTile(
                leading: Icon(Icons.build, color: Colors.grey, size: 20),
                title: Text(
                  '其余设置',
                  style: TextStyle(),
                ),
              ),
              Divider(
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
