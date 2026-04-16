import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:window_manager/window_manager.dart';
import 'fan_controllers/fan_homepage.dart';
import 'More/more_settings.dart';
import 'api/http_util.dart';

import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // 初始化 window_manager
    await windowManager.ensureInitialized();

    // 配置窗口选项
    const windowWidth = 450.0;
    const windowHeight = 800.0;

    WindowOptions windowOptions = WindowOptions(
      size: Size(windowWidth, windowHeight),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'PMSM风机监测系统',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PMSM风机监测',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        fontFamily: 'Microsoft YaHei',
      ),
      home: const MyHome(
        title: 'PMSM风机监测',
      ),
    );
  }
}

class MyHome extends StatefulWidget {
  final String title;
  const MyHome({super.key, required this.title});
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
            title: const Text(
              'PMSM风机监测系统',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            centerTitle: true,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF007AFF), Color(0xFF00C6FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {},
              )
            ]),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.air, '风机监控', true),
                  _buildNavItem(1, Icons.settings, '系统设置', false),
                ],
              ),
            ),
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

  Widget _buildNavItem(
      int index, IconData icon, String label, bool isSelected) {
    final color = isSelected ? const Color(0xFF007AFF) : Colors.grey;
    return GestureDetector(
      onTap: () {
        DefaultTabController.of(context).animateTo(index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
