import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/fan_controllers/version_update.dart';
import 'package:flutter_application_4/More/application.dart';
import '../components/common_utils.dart';
import 'fan_operation.dart';
import 'package:flutter_application_4/fan_controllers/fan_vm.dart';
import '../base/base.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../components/refresher.dart';
import 'package:flutter_application_4/components/list_view_group.dart';
import 'package:flutter_application_4/components/nodataview.dart';
import '../More/application.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../api/apis.dart';
import 'fan_demo_data.dart';

class FanHomepage {
  final String name;
  final String image;
  final String description;
  final String id;
  final String socketClient;
  final String onlineStatus;

  FanHomepage({
    required this.name,
    required this.image,
    required this.description,
    required this.id,
    required this.socketClient,
    required this.onlineStatus,
  });

  factory FanHomepage.fromJson(Map<String, dynamic> json) {
    return FanHomepage(
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      id: json['id'] ?? json['socket_client'] ?? '',
      socketClient: json['socket_client'] ?? '',
      onlineStatus: json['online_status'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': image,
        'description': description,
        'id': id,
        'socket_client': socketClient,
        'online_status': onlineStatus,
      };
}

// 设备数据类型
enum DeviceType {
  type1, // PMSM10C - datalist
  type2, // PMSM04E - datalist2
  type3, // PMSM15 - datalist3
  type4, // PMSM10A - datalist4
}

//风机编号列表页面
class FanlistNumber extends StatefulWidget {
  FanlistNumber({Key? key, required this.mt}) : super(key: key);

  final String mt;

  @override
  _FanlistNumberState createState() => _FanlistNumberState();
}

class _FanlistNumberState extends State<FanlistNumber> {
  // 根据设备类型分组的数据列表
  List<FanHomepage> datalist = []; // PMSM10C
  List<FanHomepage> datalist2 = []; // PMSM04E
  List<FanHomepage> datalist3 = []; // PMSM15
  List<FanHomepage> datalist4 = []; // PMSM10A

  // WebSocket 连接
  late WebSocketChannel _channel;
  StreamSubscription? _wsSubscription;

  // 加载状态
  bool _isLoading = true;
  String? _errorMessage;

  getOnline() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      BaseResponse baseResponse = await FanVM.online();

      if (baseResponse.success && baseResponse.data_list != null) {
        // 清空现有数据
        datalist.clear();
        datalist2.clear();
        datalist3.clear();
        datalist4.clear();

        // 遍历所有设备，根据 socket_client 分配到对应列表
        for (var item in baseResponse.data_list) {
          FanHomepage fan = FanHomepage.fromJson(item);
          // 根据 socket_client 判断设备类型
          // socket_client = "1" -> type1 (PMSM10C)
          // socket_client = "2" -> type2 (PMSM04E)
          // socket_client = "3" -> type3 (PMSM15)
          // socket_client = "4" -> type4 (PMSM10A)
          int clientId = int.tryParse(fan.socketClient) ?? 0;
          switch (clientId) {
            case 1:
              datalist.add(fan);
              break;
            case 2:
              datalist2.add(fan);
              break;
            case 3:
              datalist3.add(fan);
              break;
            case 4:
              datalist4.add(fan);
              break;
            default:
              // 未知类型，默认加入 datalist
              datalist.add(fan);
          }
        }
      } else {
        _errorMessage = baseResponse.msg ?? '获取设备列表失败';
      }
    } catch (e) {
      _errorMessage = '网络错误: $e';
    } finally {
      endRefresh();
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 初始化 WebSocket 连接
  void _initWebSocket() {
    // 根据环境选择 WebSocket URL
    String wsUrl = API.WS_BASE_URL + '/api/v1/websocket';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _wsSubscription = _channel.stream.listen(
        (data) {
          _handleWebSocketMessage(data);
        },
        onError: (error) {
          print('WebSocket error: $error');
          // 断线重连
          Future.delayed(Duration(seconds: 3), () {
            if (mounted) {
              _initWebSocket();
            }
          });
        },
        onDone: () {
          print('WebSocket closed');
        },
      );
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  // 处理 WebSocket 消息
  void _handleWebSocketMessage(dynamic data) {
    try {
      Map<String, dynamic> json = jsonDecode(data);
      String type = json['type'];

      if (type == 'device_update') {
        // 收到设备数据更新，根据设备ID刷新对应数据
        int deviceId = json['device_id'];
        // 可以在这里更新本地数据或触发 UI 刷新
        print('Device $deviceId data updated');
      }
    } catch (e) {
      print('Failed to parse WebSocket message: $e');
    }
  }

  // 版本更新
  void updateVersion() async {
    checkVersionForUpdates("1.1.2");
    try {
      BaseResponse baseResponse = await FanVM.version();
      if (baseResponse.success && baseResponse.data != null) {
        checkVersionForUpdates(baseResponse.data["version"]);
      }
    } catch (e) {
      print('Version check failed: $e');
    }
  }

  // 版本更新检测
  void checkVersionForUpdates(appVersion) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var targetVersion = appVersion.replaceAll('.', '');
    var currentVersion = packageInfo.version.replaceAll('.', '');
    if (int.parse(targetVersion) > int.parse(currentVersion)) {
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          showDialog(
              context: context,
              builder: (ctx) {
                return VersionUpdate();
              });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // 加载演示数据（禁用版本更新检测）
    _loadDemoData();
    // getOnline();  // 注释掉真实API调用
    // _initWebSocket();  // 注释掉WebSocket连接
    _reloadData();
    // updateVersion();  // 注释掉版本更新检测
  }

  // 加载演示数据
  void _loadDemoData() {
    // 清空现有数据
    datalist.clear();
    datalist2.clear();
    datalist3.clear();
    datalist4.clear();

    // 使用统一的演示数据
    final fans = FanDemoData.getFanCards();

    for (var fan in fans) {
      FanHomepage fh = FanHomepage(
        name: fan['name'] ?? '',
        image: fan['image'] ?? '',
        description: fan['description'] ?? '',
        id: fan['id'] ?? '',
        socketClient: fan['socketClient'] ?? '',
        onlineStatus: fan['onlineStatus'] ?? '0',
      );

      int clientId = int.tryParse(fh.socketClient) ?? 0;
      switch (clientId) {
        case 1:
          datalist.add(fh);
          break;
        case 2:
          datalist2.add(fh);
          break;
        case 3:
          datalist3.add(fh);
          break;
        case 4:
          datalist4.add(fh);
          break;
        default:
          datalist.add(fh);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    // _wsSubscription?.cancel();
    // _channel?.sink.close();
    super.dispose();
  }

  late ListViewGroupHandler _groupHandler;

  void _reloadData() {
    _groupHandler = ListViewGroupHandler(
      numberOfSections: 4,
      numberOfRowsInSection: (section) => 1,
      headerForSection: (section) {
        return Padding(
          padding: EdgeInsets.only(top: 20, bottom: 10),
          child: Text(
            section == 0
                ? "上位机PMSM10C"
                : section == 1
                    ? "上位机PMSM04E"
                    : section == 2
                        ? "上位机PMSM15"
                        : "上位机PMSM10A",
          ),
        );
      },
      cellForRowAtIndexPath: (indexPath) {
        if (indexPath.section == 0) {
          return datalist.isNotEmpty ? setupList(datalist) : SizedBox();
        }
        if (indexPath.section == 1) {
          return datalist2.isNotEmpty ? setupList(datalist2) : SizedBox();
        }
        if (indexPath.section == 2) {
          return datalist3.isNotEmpty ? setupList(datalist3) : SizedBox();
        }
        return datalist4.isNotEmpty ? setupList(datalist4) : SizedBox();
      },
      header: () => SizedBox(),
    );
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Widget setupList(List<FanHomepage> data) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 4.0,
      crossAxisSpacing: 2.3,
      childAspectRatio: 1.3,
      padding: EdgeInsets.all(8.0),
      children: data.map((fan) {
        return _getGridViewItemUI(context, fan);
      }).toList(),
    );
  }

  endRefresh() {
    _refreshController.refreshCompleted(resetFooterState: true);
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    // 移除嵌套的 MaterialApp，直接返回 Scaffold
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(left: 15, right: 15),
        color: Colors.white,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : (_errorMessage != null && _errorMessage!.isNotEmpty)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!,
                            style: TextStyle(color: Colors.red)),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: getOnline,
                          child: Text('重试'),
                        ),
                      ],
                    ),
                  )
                : (datalist.isEmpty &&
                        datalist2.isEmpty &&
                        datalist3.isEmpty &&
                        datalist4.isEmpty)
                    ? NoDataView("images/null_state08.png", "暂无设备")
                    : Refresher(
                        refreshController: _refreshController,
                        onRefresh: _loadDemoData,
                        onLoading: _loadDemoData,
                        child: ListView.builder(
                          itemCount: _groupHandler.allItemCount,
                          itemBuilder: (context, index) {
                            return _groupHandler.cellAtIndex(index);
                          },
                        ),
                      ),
      ),
    );
  }
}

Widget _getGridViewItemUI(BuildContext context, FanHomepage fanHomepage,
    {bool isTypeTwo = false, bool isType3 = false, bool isType4 = false}) {
  return InkWell(
    onTap: () {
      Application.isTypeTwo = isTypeTwo;
      Application.isType3 = isType3;
      Application.isType4 = isType4;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FanlistNumberControl(
            fanHomepage: fanHomepage.toJson(),
          ),
        ),
      );
    },
    child: Card(
      elevation: 4,
      shadowColor: const Color(0xFF007AFF).withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              fanHomepage.onlineStatus == "1"
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFFAFAFA)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  fanHomepage.onlineStatus == "0"
                      ? "images/上位机连接-no.png"
                      : "images/上位机连接-yes.png",
                  fit: BoxFit.contain,
                ),
              ),
              flex: 4,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                children: [
                  Text(
                    fanHomepage.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: fanHomepage.onlineStatus == "1"
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                          : const Color(0xFFF44336).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      fanHomepage.onlineStatus == "1" ? '在线' : '离线',
                      style: TextStyle(
                        fontSize: 11,
                        color: fanHomepage.onlineStatus == "1"
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF44336),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              flex: 1,
            ),
          ],
        ),
      ),
    ),
  );
}

// 第二个页面  对应风机编号点击后进行操作
class FanlistNumberControl extends StatelessWidget {
  final Map fanHomepage;
  FanlistNumberControl({Key? key, required this.fanHomepage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${fanHomepage["description"]}'),
      ),
      body: Center(
        child: FanControl(mt: '风机控制', fanHomepage: fanHomepage),
      ),
    );
  }
}
