import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../api/apis.dart';

/// 设备数据模型
class DeviceData {
  final int deviceId;
  final int address;
  final int status;
  final int fault;
  final int source;
  final int mode;
  final int rotSpeed;
  final int ntcTemp;
  final int busVoltage;
  final int uCurrent;
  final int vCurrent;
  final int wCurrent;
  final int xAcceleration;
  final int yAcceleration;
  final int zAcceleration;
  final int sumAcceleration;
  final int runTime;
  final String version;
  final DateTime updateTime;

  DeviceData({
    this.deviceId = 0,
    this.address = 0,
    this.status = 0,
    this.fault = 0,
    this.source = 0,
    this.mode = 0,
    this.rotSpeed = 0,
    this.ntcTemp = 0,
    this.busVoltage = 0,
    this.uCurrent = 0,
    this.vCurrent = 0,
    this.wCurrent = 0,
    this.xAcceleration = 0,
    this.yAcceleration = 0,
    this.zAcceleration = 0,
    this.sumAcceleration = 0,
    this.runTime = 0,
    this.version = '',
    DateTime? updateTime,
  }) : updateTime = updateTime ?? DateTime.now();

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      deviceId: json['device_id'] ?? 0,
      address: json['address'] ?? 0,
      status: json['status'] ?? 0,
      fault: json['fault'] ?? 0,
      source: json['source'] ?? 0,
      mode: json['mode'] ?? 0,
      rotSpeed: json['rot_speed'] ?? 0,
      ntcTemp: json['ntc_temp'] ?? 0,
      busVoltage: json['bus_voltage'] ?? 0,
      uCurrent: json['u_current'] ?? 0,
      vCurrent: json['v_current'] ?? 0,
      wCurrent: json['w_current'] ?? 0,
      xAcceleration: json['x_acceleration'] ?? 0,
      yAcceleration: json['y_acceleration'] ?? 0,
      zAcceleration: json['z_acceleration'] ?? 0,
      sumAcceleration: json['sum_acceleration'] ?? 0,
      runTime: json['run_time'] ?? 0,
      version: json['version'] ?? '',
      updateTime: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'device_id': deviceId,
        'address': address,
        'status': status,
        'fault': fault,
        'source': source,
        'mode': mode,
        'rot_speed': rotSpeed,
        'ntc_temp': ntcTemp,
        'bus_voltage': busVoltage,
        'u_current': uCurrent,
        'v_current': vCurrent,
        'w_current': wCurrent,
        'x_acceleration': xAcceleration,
        'y_acceleration': yAcceleration,
        'z_acceleration': zAcceleration,
        'sum_acceleration': sumAcceleration,
        'run_time': runTime,
        'version': version,
      };

  String get statusText {
    switch (status) {
      case 0:
        return '空闲';
      case 1:
        return '启动';
      case 2:
        return '运行';
      case 3:
        return '故障';
      case 4:
        return '故障死锁';
      case 5:
        return '停机';
      default:
        return '未知';
    }
  }

  String get faultText {
    if (fault == 0) return '无故障';
    List<String> faults = [];
    if (fault & 0x01 != 0) faults.add('过压');
    if (fault & 0x02 != 0) faults.add('欠压');
    if (fault & 0x04 != 0) faults.add('过载');
    if (fault & 0x08 != 0) faults.add('过温');
    if (fault & 0x20 != 0) faults.add('输出缺相');
    if (fault & 0x40 != 0) faults.add('输出短路');
    if (fault & 0x80 != 0) faults.add('风机堵转');
    return faults.join('+');
  }

  String get sourceText {
    switch (source) {
      case 0:
        return '未识别';
      case 1:
        return 'DC 110V';
      case 2:
        return 'DC 600V';
      case 3:
        return 'AC 380V';
      default:
        return '未知';
    }
  }

  String get modeText {
    switch (mode) {
      case 0:
        return '停机';
      case 1:
        return '设置转速';
      case 2:
        return '风量调节';
      case 3:
        return '电压调速';
      default:
        return '未知';
    }
  }
}

/// 设备状态 Provider
class DeviceProvider extends ChangeNotifier {
  // WebSocket 连接
  late WebSocketChannel _channel;
  StreamSubscription? _wsSubscription;

  // 设备数据映射: key = "deviceId_address"
  final Map<String, DeviceData> _deviceDataMap = {};

  // 是否连接中
  bool _isConnected = false;

  // 最后更新时间
  DateTime _lastUpdate = DateTime.now();

  // 获取所有设备数据
  Map<String, DeviceData> get deviceDataMap => Map.unmodifiable(_deviceDataMap);

  // 是否连接
  bool get isConnected => _isConnected;

  // 最后更新时间
  DateTime get lastUpdate => _lastUpdate;

  // 获取特定设备数据
  DeviceData getDeviceData(int deviceId, int address) {
    return _deviceDataMap['${deviceId}_$address'] ?? DeviceData();
  }

  // 初始化 WebSocket 连接
  void connect() {
    if (_isConnected) return;

    try {
      String wsUrl = API.WS_BASE_URL + '/api/v1/websocket';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _isConnected = true;

      _wsSubscription = _channel.stream.listen(
        (data) {
          _handleWebSocketMessage(data);
        },
        onError: (error) {
          print('[DeviceProvider] WebSocket error: $error');
          _isConnected = false;
          // 断线重连
          Future.delayed(Duration(seconds: 3), () {
            connect();
          });
          notifyListeners();
        },
        onDone: () {
          print('[DeviceProvider] WebSocket closed');
          _isConnected = false;
          notifyListeners();
        },
      );

      notifyListeners();
    } catch (e) {
      print('[DeviceProvider] Connection failed: $e');
      _isConnected = false;
    }
  }

  // 处理 WebSocket 消息
  void _handleWebSocketMessage(dynamic data) {
    try {
      Map<String, dynamic> json = jsonDecode(data);
      String type = json['type'];

      if (type == 'device_update') {
        int deviceId = json['device_id'] ?? 0;
        int address = json['address'] ?? 0;
        var updateData = json['data'];

        if (updateData != null) {
          DeviceData deviceData = DeviceData.fromJson(updateData);
          _deviceDataMap['${deviceId}_$address'] = deviceData;
          _lastUpdate = DateTime.now();
          notifyListeners();
        }
      }
    } catch (e) {
      print('[DeviceProvider] Failed to parse message: $e');
    }
  }

  // 更新设备数据（从 HTTP 查询结果）
  void updateDeviceData(int deviceId, int address, Map<String, dynamic> data) {
    DeviceData deviceData = DeviceData.fromJson({
      'device_id': deviceId,
      'address': address,
      ...data,
    });
    _deviceDataMap['${deviceId}_$address'] = deviceData;
    _lastUpdate = DateTime.now();
    notifyListeners();
  }

  // 断开连接
  void disconnect() {
    _wsSubscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
    notifyListeners();
  }

  // 清空所有数据
  void clear() {
    _deviceDataMap.clear();
    _lastUpdate = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

/// 上位机设备列表 Provider
class DeviceListProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void updateDevices(List<Map<String, dynamic>> devices) {
    _devices = devices;
    _error = '';
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clear() {
    _devices = [];
    _error = '';
    notifyListeners();
  }
}
