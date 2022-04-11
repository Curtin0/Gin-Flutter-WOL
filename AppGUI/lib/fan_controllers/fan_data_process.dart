//数据处理
import '../More/application.dart';

// 构造函数
List decodeQuery(dataquery) {
  List listData = Application.isTypeTwo

//@*****************************************************************************
//@类型二上位机 PMSM04E
//@*****************************************************************************
      ? [
          {
            "title": '数据刷新时间',
            "data": dataquery["now_time"],
            "unit": '',
            "imageUrl": 'images/time.png',
          },
          {
            "title": '风机物理地址',
            "data": "0x" + (int.parse(dataquery["address"]) - 18).toString(),
            "unit": ' ',
            "imageUrl": 'images/编号.png',
          },
          {
            "title": '当前状态',
            "data": dataquery["status"],
            "unit": ' ',
            "imageUrl": 'images/当前状态.png',
          },
          {
            "title": '当前故障',
            "data": dataquery["fault"],
            "unit": ' ',
            "imageUrl": 'images/当前故障.png',
          },
          {
            "title": '运行模式',
            "data": dataquery["mode"],
            "unit": ' ',
            "imageUrl": 'images/运行模式.png',
          },
          {
            "title": '风机转速',
            "data": dataquery["rot_speed"],
            "unit": ' rpm',
            "imageUrl": 'images/转速.png',
          },
          {
            "title": 'NTC温度',
            "data": dataquery["ntc_temp"],
            "unit": ' ℃',
            "imageUrl": 'images/温度2.png',
          },
          {
            "title": '母线电压',
            "data": dataquery["bus_voltage"],
            "unit": ' V',
            "imageUrl": 'images/电压.png',
          },
          {
            "title": 'U相电流',
            "data": dataquery["u_current"],
            "unit": ' mA',
            "imageUrl": 'images/电流.png',
          },
          {
            "title": 'V相电流',
            "data": dataquery["v_current"],
            "unit": ' mA',
            "imageUrl": 'images/电流2.png',
          },
          {
            "title": 'W相电流',
            "data": dataquery["w_current"],
            "unit": ' mA',
            "imageUrl": 'images/电流3.png',
          },
          {
            "title": '已运行时间',
            "data": dataquery["run_time"],
            "unit": ' s',
            "imageUrl": 'images/累计运行时间.png',
          },
          {
            "title": '软件版本',
            "data": 'V' +
                (int.parse(dataquery["version"]) / 100).toStringAsFixed(2),
            //"data": dataquery["version"],
            "unit": ' ',
            "imageUrl": 'images/版本.png',
          },
          {
            "title": '波特率',
            "data": dataquery["baud_rate"],
            //"data": "0",
            "unit": ' ',
            "imageUrl": 'images/振动加速度.png',
          },
        ]
//@*****************************************************************************
//@类型三上位机 PMSM15
//@*****************************************************************************
      : Application.isType3
          ? [
              {
                "title": '数据刷新时间',
                "data": dataquery["now_time"],
                "unit": '',
                "imageUrl": 'images/time.png',
              },
              {
                "title": '当前状态',
                "data": dataquery["status"],
                //"data": "0",
                "unit": ' ',
                "imageUrl": 'images/当前状态.png',
              },
              {
                "title": '风机转速',
                "data": dataquery["rot_speed"],
                "unit": ' rpm',
                "imageUrl": 'images/转速.png',
              },
              {
                "title": '模块温度',
                "data": dataquery["ntc_temp"],
                "unit": ' ℃',
                "imageUrl": 'images/温度2.png',
              },
              {
                "title": '母线电压',
                "data": dataquery["bus_voltage2"],
                "unit": ' V',
                "imageUrl": 'images/电压.png',
              },
              {
                "title": 'U相电流',
                "data": dataquery["u_current"],
                "unit": ' mA',
                "imageUrl": 'images/电流.png',
              },
              {
                "title": 'V相电流',
                "data": dataquery["v_current"],
                "unit": ' mA',
                "imageUrl": 'images/电流2.png',
              },
              {
                "title": 'W相电流',
                "data": dataquery["w_current"],
                "unit": ' mA',
                "imageUrl": 'images/电流3.png',
              },
              {
                "title": '调速电压',
                "data": dataquery["bus_voltage"],
                "unit": ' mV',
                "imageUrl": 'images/电压.png',
              },
            ]
//@*****************************************************************************
//@类型四上位机 PMSM10A
//@*****************************************************************************
          : Application.isType4
              ? [
                  {
                    "title": '数据刷新时间',
                    "data": dataquery["now_time"],
                    "unit": '',
                    "imageUrl": 'images/time.png',
                  },
                  {
                    "title": '风机物理地址',
                    "data": "0x" +
                        (int.parse(dataquery["address"]) - 12).toString(),
                    "unit": ' ',
                    "imageUrl": 'images/编号.png',
                  },
                  {
                    "title": '当前状态',
                    "data": dataquery["status"],
                    "unit": ' ',
                    "imageUrl": 'images/当前状态.png',
                  },
                  {
                    "title": '当前故障',
                    "data": dataquery["fault"],
                    "unit": ' ',
                    "imageUrl": 'images/当前故障.png',
                  },
                  {
                    "title": '输入源',
                    "data": dataquery["source"],
                    "unit": ' ',
                    "imageUrl": 'images/输入源.png',
                  },
                  {
                    "title": '运行模式',
                    "data": dataquery["mode"],
                    "unit": ' ',
                    "imageUrl": 'images/运行模式.png',
                  },
                  {
                    "title": '风机转速',
                    "data": dataquery["rot_speed"],
                    "unit": ' rpm',
                    "imageUrl": 'images/转速.png',
                  },
                  {
                    "title": 'NTC温度',
                    "data": dataquery["ntc_temp"],
                    "unit": ' ℃',
                    "imageUrl": 'images/温度2.png',
                  },
                  {
                    "title": '母线电压',
                    "data": dataquery["bus_voltage"],
                    "unit": ' V',
                    "imageUrl": 'images/电压.png',
                  },
                  {
                    "title": 'U相电流',
                    "data": dataquery["u_current"],
                    "unit": ' mA',
                    "imageUrl": 'images/电流.png',
                  },
                  {
                    "title": 'V相电流',
                    "data": dataquery["v_current"],
                    "unit": ' mA',
                    "imageUrl": 'images/电流2.png',
                  },
                  {
                    "title": 'W相电流',
                    "data": dataquery["w_current"],
                    "unit": ' mA',
                    "imageUrl": 'images/电流3.png',
                  },
                  {
                    "title": 'X轴振动加速度',
                    //"data": dataquery["x_acceleration"],
                    "data": "0",
                    "unit": ' mg',
                    "imageUrl": 'images/x轴加速度.png',
                  },
                  {
                    "title": 'Y轴振动加速度',
                    //"data": dataquery["y_acceleration"],
                    "data": "0",
                    "unit": ' mg',
                    "imageUrl": 'images/y轴加速度.png',
                  },
                  {
                    "title": 'Z轴振动加速度',
                    //"data": dataquery["z_acceleration"],
                    "data": "0",
                    "unit": ' mg',
                    "imageUrl": 'images/z轴加速度.png',
                  },
                  {
                    "title": '加速度矢量和',
                    //"data": dataquery["sum_acceleration"],
                    "data": "0",
                    "unit": ' mg',
                    "imageUrl": 'images/振动加速度.png',
                  },
                  {
                    "title": '已运行时间',
                    "data": dataquery["run_time"],
                    "unit": ' s',
                    "imageUrl": 'images/累计运行时间.png',
                  },
                  {
                    "title": '软件版本',
                    "data": 'V' +
                        (int.parse(dataquery["version"]) / 100)
                            .toStringAsFixed(2),
                    //"data": dataquery["version"],
                    "unit": ' ',
                    "imageUrl": 'images/版本.png',
                  },
                ]
//@*****************************************************************************
//@类型一上位机 PMSM10C
//@*****************************************************************************
              : [
                  {
                    "title": '数据刷新时间',
                    "data": dataquery["now_time"],
                    "unit": '',
                    "imageUrl": 'images/time.png',
                  },
                  {
                    "title": '风机物理地址',
                    "data": "0x" +
                        (int.parse(dataquery["address"]) - 12).toString(),
                    "unit": ' ',
                    "imageUrl": 'images/编号.png',
                  },
                  {
                    "title": '当前状态',
                    "data": dataquery["status"],
                    "unit": ' ',
                    "imageUrl": 'images/当前状态.png',
                  },
                  {
                    "title": '当前故障',
                    "data": dataquery["fault"],
                    "unit": ' ',
                    "imageUrl": 'images/当前故障.png',
                  },
                  {
                    "title": '输入源',
                    "data": dataquery["source"],
                    "unit": ' ',
                    "imageUrl": 'images/输入源.png',
                  },
                  {
                    "title": '运行模式',
                    "data": dataquery["mode"],
                    "unit": ' ',
                    "imageUrl": 'images/运行模式.png',
                  },
                  {
                    "title": '风机转速',
                    "data": dataquery["rot_speed"],
                    "unit": ' rpm',
                    "imageUrl": 'images/转速.png',
                  },
                  {
                    "title": 'NTC温度',
                    "data": dataquery["ntc_temp"],
                    "unit": ' ℃',
                    "imageUrl": 'images/温度2.png',
                  },
                  {
                    "title": '母线电压',
                    "data": dataquery["bus_voltage"],
                    "unit": ' V',
                    "imageUrl": 'images/电压.png',
                  },
                  {
                    "title": 'U相电流',
                    "data": dataquery["u_current"],
                    "unit": ' mA',
                    "imageUrl": 'images/电流.png',
                  },
                  {
                    "title": 'V相电流',
                    "data": dataquery["v_current"],
                    "unit": ' mA',
                    "imageUrl": 'images/电流2.png',
                  },
                  {
                    "title": 'W相电流',
                    "data": dataquery["w_current"],
                    "unit": ' mA',
                    "imageUrl": 'images/电流3.png',
                  },
                  {
                    "title": 'X轴振动加速度',
                    "data": dataquery["x_acceleration"],
                    //"data": "0",
                    "unit": ' mg',
                    "imageUrl": 'images/x轴加速度.png',
                  },
                  {
                    "title": 'Y轴振动加速度',
                    "data": dataquery["y_acceleration"],
                    //"data": "0",
                    "unit": ' mg',
                    "imageUrl": 'images/y轴加速度.png',
                  },
                  {
                    "title": 'Z轴振动加速度',
                    "data": dataquery["z_acceleration"],
                    //"data": "0",
                    "unit": ' mg',
                    "imageUrl": 'images/z轴加速度.png',
                  },
                  {
                    "title": '加速度矢量和',
                    "data": dataquery["sum_acceleration"],
                    //"data": "0",
                    "unit": ' mg',
                    "imageUrl": 'images/振动加速度.png',
                  },
                  {
                    "title": '已运行时间',
                    "data": dataquery["run_time"],
                    "unit": ' s',
                    "imageUrl": 'images/累计运行时间.png',
                  },
                  {
                    "title": '软件版本',
                    //"data": 'V' + (int.parse(dataquery["version"]) / 100).toStringAsFixed(2),
                    "data": dataquery["version"],
                    "unit": ' ',
                    "imageUrl": 'images/版本.png',
                  },
                ];

  return listData;
}

List decodeQuery2(dataquery) {
  List listData = [
    {
      "title": '风机转速',
      "data": dataquery["rot_speed"],
      "unit": ' rpm',
      "imageUrl": 'images/转速.png',
    },
    {
      "title": 'U相电流',
      "data": dataquery["u_current"],
      "unit": ' mA',
      "imageUrl": 'images/电流.png',
    },
    {
      "title": 'NTC温度',
      "data": dataquery["ntc_temp"],
      "unit": ' ℃',
      "imageUrl": 'images/温度2.png',
    },
    {
      "title": 'V相电流',
      "data": dataquery["v_current"],
      "unit": ' mA',
      "imageUrl": 'images/电流2.png',
    },
    {
      "title": '母线电压',
      "data": dataquery["bus_voltage"],
      "unit": ' V',
      "imageUrl": 'images/电压.png',
    },
    {
      "title": 'W相电流',
      "data": dataquery["w_current"],
      "unit": ' mA',
      "imageUrl": 'images/电流3.png',
    },
  ];

  return listData;
}
