import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'fan_controllers/fan_homepage.dart';
import 'More/more_settings.dart';
import 'api/http_util.dart';

import 'package:flutter/widgets.dart';
import 'package:window_size/window_size.dart' as window_size;
import 'package:window_size/window_size.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final WindowSizeService windowSizeService = WindowSizeService();
    windowSizeService.initialize();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tongye',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MyHome(
        title: 'Tongye',
      ),
    );
  }
}

class MyHome extends StatefulWidget {
  final String title;
  MyHome({Key key, @required this.title}) : super(key: key);
  @override
  _MyHomeState createState() => new _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  void initState() {
    super.initState();
    HttpUtil.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            title: Text('PMSM风机数据监测软件'),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
              )
            ]),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(color: Colors.blueGrey),
          height: 50,
          child: TabBar(
            labelStyle: TextStyle(height: 0, fontSize: 10),
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.speaker_phone),
                text: '风机操作',
              ),
              Tab(
                icon: Icon(Icons.more),
                text: '更多',
              ),
            ],
          ),
        ),
        body: TabBarView(children: <Widget>[
          FanlistNumber(
            mt: 'FanControlHomePage',
          ),
          MoreSettings(
            mt: 'MoreSettings',
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

//@设置windows应用初始尺寸
class PlatformUtils {
  static bool _isWeb() {
    return kIsWeb == true;
  }

  static bool get isWeb => _isWeb();
}

class WindowSizeService {
  static const double width = 400;
  static const double height = 700;

  Future<PlatformWindow> _getPlatformWindow() async {
    return await window_size.getWindowInfo();
  }

  void _setWindowSize(PlatformWindow platformWindow) {
    final Rect frame = Rect.fromCenter(
      center: Offset(
        platformWindow.frame.center.dx,
        platformWindow.frame.center.dy,
      ),
      width: width,
      height: height,
    );

    window_size.setWindowFrame(frame);

    setWindowTitle(
      '${Platform.operatingSystem} App',
    );

    /// 此处的判断是指，只要是苹果或者微软，那么设置其最大尺寸和最小尺寸， 可以另作调整
    if (Platform.isMacOS || Platform.isWindows) {
      window_size.setWindowMinSize(Size(width, height));
      window_size.setWindowMaxSize(Size(500, 1200));
    }
  }

  Future<void> initialize() async {
    PlatformWindow platformWindow = await _getPlatformWindow();

    if (platformWindow.screen != null) {
      if (platformWindow.screen.visibleFrame.width != 800 ||
          platformWindow.screen.visibleFrame.height != 500) {
        _setWindowSize(platformWindow);
      }
    }
  }

  void setWindowTitle(String title) {
    window_size.setWindowTitle(title);
  }
}
