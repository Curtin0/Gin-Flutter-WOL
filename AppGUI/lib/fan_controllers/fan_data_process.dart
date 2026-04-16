// 数据处理 - 重构版本
// 使用配置对象代替嵌套三元运算符

import '../More/application.dart';

/// 风机数据类型配置
class FanDataItem {
  final String title;
  final String dataKey;
  final String unit;
  final String imageUrl;
  final String? defaultValue;
  final String Function(String)? transform;

  const FanDataItem({
    required this.title,
    required this.dataKey,
    required this.unit,
    required this.imageUrl,
    this.defaultValue,
    this.transform,
  });
}

/// 按设备类型配置数据项
class FanDataConfig {
  static final Map<String, List<FanDataItem>> configs = {
    // 类型二 PMSM04E
    'type2': [
      FanDataItem(
          title: '数据刷新时间',
          dataKey: 'now_time',
          unit: '',
          imageUrl: 'images/time.png'),
      FanDataItem(
          title: '风机物理地址',
          dataKey: 'address',
          unit: ' ',
          imageUrl: 'images/编号.png',
          transform: (v) => "0x${(int.parse(v) - 18).toString()}"),
      FanDataItem(
          title: '当前状态',
          dataKey: 'status',
          unit: ' ',
          imageUrl: 'images/当前状态.png'),
      FanDataItem(
          title: '当前故障',
          dataKey: 'fault',
          unit: ' ',
          imageUrl: 'images/当前故障.png'),
      FanDataItem(
          title: '运行模式',
          dataKey: 'mode',
          unit: ' ',
          imageUrl: 'images/运行模式.png'),
      FanDataItem(
          title: '风机转速',
          dataKey: 'rot_speed',
          unit: ' rpm',
          imageUrl: 'images/转速.png'),
      FanDataItem(
          title: 'NTC温度',
          dataKey: 'ntc_temp',
          unit: ' ℃',
          imageUrl: 'images/温度2.png'),
      FanDataItem(
          title: '母线电压',
          dataKey: 'bus_voltage',
          unit: ' V',
          imageUrl: 'images/电压.png'),
      FanDataItem(
          title: 'U相电流',
          dataKey: 'u_current',
          unit: ' mA',
          imageUrl: 'images/电流.png'),
      FanDataItem(
          title: 'V相电流',
          dataKey: 'v_current',
          unit: ' mA',
          imageUrl: 'images/电流2.png'),
      FanDataItem(
          title: 'W相电流',
          dataKey: 'w_current',
          unit: ' mA',
          imageUrl: 'images/电流3.png'),
      FanDataItem(
          title: '已运行时间',
          dataKey: 'run_time',
          unit: ' s',
          imageUrl: 'images/累计运行时间.png'),
      FanDataItem(
          title: '软件版本',
          dataKey: 'version',
          unit: ' ',
          imageUrl: 'images/版本.png',
          transform: (v) => 'V${(int.parse(v) / 100).toStringAsFixed(2)}'),
      FanDataItem(
          title: '波特率',
          dataKey: 'baud_rate',
          unit: ' ',
          imageUrl: 'images/振动加速度.png'),
    ],
    // 类型三 PMSM15
    'type3': [
      FanDataItem(
          title: '数据刷新时间',
          dataKey: 'now_time',
          unit: '',
          imageUrl: 'images/time.png'),
      FanDataItem(
          title: '当前状态',
          dataKey: 'status',
          unit: ' ',
          imageUrl: 'images/当前状态.png'),
      FanDataItem(
          title: '风机转速',
          dataKey: 'rot_speed',
          unit: ' rpm',
          imageUrl: 'images/转速.png'),
      FanDataItem(
          title: '模块温度',
          dataKey: 'ntc_temp',
          unit: ' ℃',
          imageUrl: 'images/温度2.png'),
      FanDataItem(
          title: '母线电压',
          dataKey: 'bus_voltage2',
          unit: ' V',
          imageUrl: 'images/电压.png'),
      FanDataItem(
          title: 'U相电流',
          dataKey: 'u_current',
          unit: ' mA',
          imageUrl: 'images/电流.png'),
      FanDataItem(
          title: 'V相电流',
          dataKey: 'v_current',
          unit: ' mA',
          imageUrl: 'images/电流2.png'),
      FanDataItem(
          title: 'W相电流',
          dataKey: 'w_current',
          unit: ' mA',
          imageUrl: 'images/电流3.png'),
      FanDataItem(
          title: '调速电压',
          dataKey: 'bus_voltage',
          unit: ' mV',
          imageUrl: 'images/电压.png'),
    ],
    // 类型四 PMSM10A
    'type4': [
      FanDataItem(
          title: '数据刷新时间',
          dataKey: 'now_time',
          unit: '',
          imageUrl: 'images/time.png'),
      FanDataItem(
          title: '风机物理地址',
          dataKey: 'address',
          unit: ' ',
          imageUrl: 'images/编号.png',
          transform: (v) => "0x${(int.parse(v) - 12).toString()}"),
      FanDataItem(
          title: '当前状态',
          dataKey: 'status',
          unit: ' ',
          imageUrl: 'images/当前状态.png'),
      FanDataItem(
          title: '当前故障',
          dataKey: 'fault',
          unit: ' ',
          imageUrl: 'images/当前故障.png'),
      FanDataItem(
          title: '输入源',
          dataKey: 'source',
          unit: ' ',
          imageUrl: 'images/输入源.png'),
      FanDataItem(
          title: '运行模式',
          dataKey: 'mode',
          unit: ' ',
          imageUrl: 'images/运行模式.png'),
      FanDataItem(
          title: '风机转速',
          dataKey: 'rot_speed',
          unit: ' rpm',
          imageUrl: 'images/转速.png'),
      FanDataItem(
          title: 'NTC温度',
          dataKey: 'ntc_temp',
          unit: ' ℃',
          imageUrl: 'images/温度2.png'),
      FanDataItem(
          title: '母线电压',
          dataKey: 'bus_voltage',
          unit: ' V',
          imageUrl: 'images/电压.png'),
      FanDataItem(
          title: 'U相电流',
          dataKey: 'u_current',
          unit: ' mA',
          imageUrl: 'images/电流.png'),
      FanDataItem(
          title: 'V相电流',
          dataKey: 'v_current',
          unit: ' mA',
          imageUrl: 'images/电流2.png'),
      FanDataItem(
          title: 'W相电流',
          dataKey: 'w_current',
          unit: ' mA',
          imageUrl: 'images/电流3.png'),
      FanDataItem(
          title: 'X轴振动加速度',
          dataKey: 'x_acceleration',
          unit: ' mg',
          imageUrl: 'images/x轴加速度.png',
          defaultValue: '0'),
      FanDataItem(
          title: 'Y轴振动加速度',
          dataKey: 'y_acceleration',
          unit: ' mg',
          imageUrl: 'images/y轴加速度.png',
          defaultValue: '0'),
      FanDataItem(
          title: 'Z轴振动加速度',
          dataKey: 'z_acceleration',
          unit: ' mg',
          imageUrl: 'images/z轴加速度.png',
          defaultValue: '0'),
      FanDataItem(
          title: '加速度矢量和',
          dataKey: 'sum_acceleration',
          unit: ' mg',
          imageUrl: 'images/振动加速度.png',
          defaultValue: '0'),
      FanDataItem(
          title: '已运行时间',
          dataKey: 'run_time',
          unit: ' s',
          imageUrl: 'images/累计运行时间.png'),
      FanDataItem(
          title: '软件版本',
          dataKey: 'version',
          unit: ' ',
          imageUrl: 'images/版本.png',
          transform: (v) => 'V${(int.parse(v) / 100).toStringAsFixed(2)}'),
    ],
    // 类型一 PMSM10C (默认)
    'type1': [
      FanDataItem(
          title: '数据刷新时间',
          dataKey: 'now_time',
          unit: '',
          imageUrl: 'images/time.png'),
      FanDataItem(
          title: '风机物理地址',
          dataKey: 'address',
          unit: ' ',
          imageUrl: 'images/编号.png',
          transform: (v) => "0x${(int.parse(v) - 12).toString()}"),
      FanDataItem(
          title: '当前状态',
          dataKey: 'status',
          unit: ' ',
          imageUrl: 'images/当前状态.png'),
      FanDataItem(
          title: '当前故障',
          dataKey: 'fault',
          unit: ' ',
          imageUrl: 'images/当前故障.png'),
      FanDataItem(
          title: '输入源',
          dataKey: 'source',
          unit: ' ',
          imageUrl: 'images/输入源.png'),
      FanDataItem(
          title: '运行模式',
          dataKey: 'mode',
          unit: ' ',
          imageUrl: 'images/运行模式.png'),
      FanDataItem(
          title: '风机转速',
          dataKey: 'rot_speed',
          unit: ' rpm',
          imageUrl: 'images/转速.png'),
      FanDataItem(
          title: 'NTC温度',
          dataKey: 'ntc_temp',
          unit: ' ℃',
          imageUrl: 'images/温度2.png'),
      FanDataItem(
          title: '母线电压',
          dataKey: 'bus_voltage',
          unit: ' V',
          imageUrl: 'images/电压.png'),
      FanDataItem(
          title: 'U相电流',
          dataKey: 'u_current',
          unit: ' mA',
          imageUrl: 'images/电流.png'),
      FanDataItem(
          title: 'V相电流',
          dataKey: 'v_current',
          unit: ' mA',
          imageUrl: 'images/电流2.png'),
      FanDataItem(
          title: 'W相电流',
          dataKey: 'w_current',
          unit: ' mA',
          imageUrl: 'images/电流3.png'),
      FanDataItem(
          title: 'X轴振动加速度',
          dataKey: 'x_acceleration',
          unit: ' mg',
          imageUrl: 'images/x轴加速度.png'),
      FanDataItem(
          title: 'Y轴振动加速度',
          dataKey: 'y_acceleration',
          unit: ' mg',
          imageUrl: 'images/y轴加速度.png'),
      FanDataItem(
          title: 'Z轴振动加速度',
          dataKey: 'z_acceleration',
          unit: ' mg',
          imageUrl: 'images/z轴加速度.png'),
      FanDataItem(
          title: '加速度矢量和',
          dataKey: 'sum_acceleration',
          unit: ' mg',
          imageUrl: 'images/振动加速度.png'),
      FanDataItem(
          title: '已运行时间',
          dataKey: 'run_time',
          unit: ' s',
          imageUrl: 'images/累计运行时间.png'),
      FanDataItem(
          title: '软件版本',
          dataKey: 'version',
          unit: ' ',
          imageUrl: 'images/版本.png'),
    ],
  };

  /// 获取当前设备类型对应的配置Key
  static String get _configKey {
    if (Application.isTypeTwo) return 'type2';
    if (Application.isType3) return 'type3';
    if (Application.isType4) return 'type4';
    return 'type1';
  }

  /// 解码查询数据
  static List decodeQuery(dataquery) {
    final config = configs[_configKey] ?? configs['type1']!;
    return config.map((item) {
      String value =
          dataquery[item.dataKey]?.toString() ?? item.defaultValue ?? '0';
      if (item.transform != null && value.isNotEmpty) {
        try {
          value = item.transform!(value);
        } catch (e) {
          // 转换失败使用原值
        }
      }
      return {
        'title': item.title,
        'data': value,
        'unit': item.unit,
        'imageUrl': item.imageUrl,
      };
    }).toList();
  }

  /// 解码控制参数数据
  static List decodeQuery2(dataquery) {
    // 控制参数所有类型一致
    return [
      {
        'title': '风机转速',
        'data': dataquery["rot_speed"] ?? '0',
        'unit': ' rpm',
        'imageUrl': 'images/转速.png'
      },
      {
        'title': 'U相电流',
        'data': dataquery["u_current"] ?? '0',
        'unit': ' mA',
        'imageUrl': 'images/电流.png'
      },
      {
        'title': 'NTC温度',
        'data': dataquery["ntc_temp"] ?? '0',
        'unit': ' ℃',
        'imageUrl': 'images/温度2.png'
      },
      {
        'title': 'V相电流',
        'data': dataquery["v_current"] ?? '0',
        'unit': ' mA',
        'imageUrl': 'images/电流2.png'
      },
      {
        'title': '母线电压',
        'data': dataquery["bus_voltage"] ?? '0',
        'unit': ' V',
        'imageUrl': 'images/电压.png'
      },
      {
        'title': 'W相电流',
        'data': dataquery["w_current"] ?? '0',
        'unit': ' mA',
        'imageUrl': 'images/电流3.png'
      },
    ];
  }
}

// 兼容旧API
List decodeQuery(dataquery) => FanDataConfig.decodeQuery(dataquery);
List decodeQuery2(dataquery) => FanDataConfig.decodeQuery2(dataquery);
