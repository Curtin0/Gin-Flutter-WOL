/// 演示数据统一管理
/// 解决演示数据在多处重复定义的问题

class FanDemoData {
  FanDemoData._();

  /// 获取风机监测演示数据
  static List<Map<String, String>> getMonitoringData() {
    return [
      {
        "title": "数据刷新时间",
        "data": "2026-04-16 22:11:38",
        "unit": "",
        "imageUrl": "images/time.png"
      },
      {
        "title": "风机物理地址",
        "data": "0x01",
        "unit": " ",
        "imageUrl": "images/编号.png"
      },
      {
        "title": "当前状态",
        "data": "运行中",
        "unit": " ",
        "imageUrl": "images/当前状态.png"
      },
      {
        "title": "当前故障",
        "data": "无",
        "unit": " ",
        "imageUrl": "images/当前故障.png"
      },
      {"title": "输入源", "data": "本地", "unit": " ", "imageUrl": "images/输入源.png"},
      {
        "title": "运行模式",
        "data": "自动",
        "unit": " ",
        "imageUrl": "images/运行模式.png"
      },
      {
        "title": "风机转速",
        "data": "1500",
        "unit": " rpm",
        "imageUrl": "images/转速.png"
      },
      {
        "title": "NTC温度",
        "data": "45",
        "unit": " ℃",
        "imageUrl": "images/温度2.png"
      },
      {
        "title": "母线电压",
        "data": "380",
        "unit": " V",
        "imageUrl": "images/电压.png"
      },
      {
        "title": "U相电流",
        "data": "12.5",
        "unit": " A",
        "imageUrl": "images/电流.png"
      },
      {
        "title": "V相电流",
        "data": "12.3",
        "unit": " A",
        "imageUrl": "images/电流2.png"
      },
      {
        "title": "W相电流",
        "data": "12.4",
        "unit": " A",
        "imageUrl": "images/电流3.png"
      },
      {
        "title": "X轴振动加速度",
        "data": "10",
        "unit": " mg",
        "imageUrl": "images/x轴加速度.png"
      },
      {
        "title": "Y轴振动加速度",
        "data": "8",
        "unit": " mg",
        "imageUrl": "images/y轴加速度.png"
      },
      {
        "title": "Z轴振动加速度",
        "data": "12",
        "unit": " mg",
        "imageUrl": "images/z轴加速度.png"
      },
      {
        "title": "加速度矢量和",
        "data": "18",
        "unit": " mg",
        "imageUrl": "images/振动加速度.png"
      },
      {
        "title": "已运行时间",
        "data": "43200",
        "unit": " s",
        "imageUrl": "images/累计运行时间.png"
      },
      {
        "title": "软件版本",
        "data": "V1.0.0",
        "unit": " ",
        "imageUrl": "images/版本.png"
      },
    ];
  }

  /// 获取控制参数演示数据
  static List<Map<String, String>> getControlData() {
    return [
      {
        "title": "风机转速",
        "data": "1500",
        "unit": " rpm",
        "imageUrl": "images/转速.png"
      },
      {
        "title": "U相电流",
        "data": "12.5",
        "unit": " A",
        "imageUrl": "images/电流.png"
      },
      {
        "title": "NTC温度",
        "data": "45",
        "unit": " ℃",
        "imageUrl": "images/温度2.png"
      },
      {
        "title": "V相电流",
        "data": "12.3",
        "unit": " A",
        "imageUrl": "images/电流2.png"
      },
      {
        "title": "母线电压",
        "data": "380",
        "unit": " V",
        "imageUrl": "images/电压.png"
      },
      {
        "title": "W相电流",
        "data": "12.4",
        "unit": " A",
        "imageUrl": "images/电流3.png"
      },
    ];
  }

  /// 获取风机列表演示数据
  static List<Map<String, dynamic>> getFanList() {
    return [
      {"address": "53", "name": "1号风机"},
      {"address": "54", "name": "2号风机"},
      {"address": "55", "name": "3号风机"},
      {"address": "56", "name": "4号风机"},
      {"address": "57", "name": "5号风机"},
      {"address": "58", "name": "6号风机"},
      {"address": "59", "name": "7号风机"},
      {"address": "60", "name": "8号风机"},
    ];
  }

  /// 获取风机卡片演示数据
  static List<Map<String, String>> getFanCards() {
    return [
      {
        "name": "1号风机",
        "image": "images/风机.png",
        "description": "PMSM10C型变频器",
        "id": "FAN001",
        "socketClient": "1",
        "onlineStatus": "1"
      },
      {
        "name": "2号风机",
        "image": "images/风机.png",
        "description": "PMSM10C型变频器",
        "id": "FAN002",
        "socketClient": "1",
        "onlineStatus": "1"
      },
      {
        "name": "3号风机",
        "image": "images/风机.png",
        "description": "PMSM04E型变频器",
        "id": "FAN003",
        "socketClient": "2",
        "onlineStatus": "1"
      },
      {
        "name": "4号风机",
        "image": "images/风机.png",
        "description": "PMSM04E型变频器",
        "id": "FAN004",
        "socketClient": "2",
        "onlineStatus": "0"
      },
      {
        "name": "5号风机",
        "image": "images/风机.png",
        "description": "PMSM15型变频器",
        "id": "FAN005",
        "socketClient": "3",
        "onlineStatus": "1"
      },
      {
        "name": "6号风机",
        "image": "images/风机.png",
        "description": "PMSM15型变频器",
        "id": "FAN006",
        "socketClient": "3",
        "onlineStatus": "1"
      },
      {
        "name": "7号风机",
        "image": "images/风机.png",
        "description": "PMSM10A型变频器",
        "id": "FAN007",
        "socketClient": "4",
        "onlineStatus": "1"
      },
      {
        "name": "8号风机",
        "image": "images/风机.png",
        "description": "PMSM10A型变频器",
        "id": "FAN008",
        "socketClient": "4",
        "onlineStatus": "0"
      },
    ];
  }
}
