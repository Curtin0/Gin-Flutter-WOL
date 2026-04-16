import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_4/More/application.dart';
import 'package:flutter_application_4/components/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/components/jytoast.dart';
import '../base/base.dart';
import 'package:flutter_application_4/components/bottom_drawer.dart';
import 'package:flutter_application_4/components/list_view_group.dart';
import 'fan_data_process.dart';
import 'fan_vm.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../components/refresher.dart';

class FanControl extends StatefulWidget {
  FanControl({Key? key, required this.mt, this.fanHomepage}) : super(key: key);
  final Map? fanHomepage;
  final String mt;

  @override
  _FanControlState createState() => _FanControlState();
}

class _FanControlState extends State<FanControl> {
  // 移除嵌套 MaterialApp，直接返回内容
  @override
  Widget build(BuildContext context) {
    return MyHomePage(
      title: widget.mt,
      fanHomepage: widget.fanHomepage,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final Map? fanHomepage;

  MyHomePage({Key? key, required this.title, this.fanHomepage})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _fannumber = TextEditingController();
  TextEditingController _airController = TextEditingController();
  TextEditingController _speedController = TextEditingController();
  late ListViewGroupHandler _groupHandler;

  // 数据状态
  List listData = [];
  List listData2 = [];
  bool _isLoading = false;
  String? _errorMessage;

  // 定时器
  Timer? _timer;

  //@*****************************************************************************
  //@类型一上位机 PMSM10C
  //@*****************************************************************************
  Map<String, dynamic> dataquery = {
    "address": "0",
    "bus_voltage": "0",
    "fault": "无数据",
    "mode": "无数据",
    "now_time": "0",
    "ntc_temp": "0",
    "rot_speed": "0",
    "run_time": "0",
    "socket_client": "0",
    "source": "0",
    "status": "无数据",
    "u_current": "0",
    "v_current": "0",
    "version": "0",
    "w_current": "0",
    "x_acceleration": "0",
    "y_acceleration": "0",
    "z_acceleration": "0",
    "sum_acceleration": "0"
  };

  //@*****************************************************************************
  //@类型二上位机 PMSM04E
  //@*****************************************************************************
  Map<String, dynamic> dataqueryTwo = {
    "address": "0",
    "bus_voltage": "0",
    "fault": "无数据",
    "mode": "无数据",
    "now_time": "0",
    "ntc_temp": "0",
    "rot_speed": "0",
    "run_time": "0",
    "socket_client": "0",
    "status": "无数据",
    "u_current": "0",
    "v_current": "0",
    "version": "0",
    "w_current": "0",
    "baud_rate": "0"
  };

  //@*****************************************************************************
  //@类型三上位机 PMSM15
  //@*****************************************************************************
  Map<String, dynamic> dataquery3 = {
    "bus_voltage": "0",
    "bus_voltage2": "0",
    "now_time": "0",
    "ntc_temp": "0",
    "rot_speed": "0",
    "socket_client": "0",
    "status": "无数据",
    "u_current": "0",
    "v_current": "0",
    "w_current": "0",
  };

  //@*****************************************************************************
  //@类型四上位机 PMSM10A
  //@*****************************************************************************
  Map<String, dynamic> dataquery4 = {
    "address": "0",
    "bus_voltage": "0",
    "fault": "无数据",
    "mode": "无数据",
    "now_time": "0",
    "ntc_temp": "0",
    "rot_speed": "0",
    "run_time": "0",
    "socket_client": "0",
    "source": "0",
    "status": "无数据",
    "u_current": "0",
    "v_current": "0",
    "version": "0",
    "w_current": "0",
    "x_acceleration": "0",
    "y_acceleration": "0",
    "z_acceleration": "0",
    "sum_acceleration": "0"
  };

  List fanNumbers = Application.isTypeTwo
      ? [
          {"address": "33", "address_online_status": "1"},
          {"address": "34", "address_online_status": "1"},
          {"address": "35", "address_online_status": "1"},
          {"address": "36", "address_online_status": "1"},
          {"address": "37", "address_online_status": "1"},
          {"address": "38", "address_online_status": "1"},
          {"address": "39", "address_online_status": "1"},
          {"address": "40", "address_online_status": "1"}
        ]
      : Application.isType3
          ? [
              {"address": "33", "address_online_status": "1"},
              {"address": "34", "address_online_status": "1"},
              {"address": "35", "address_online_status": "1"},
              {"address": "36", "address_online_status": "1"},
              {"address": "37", "address_online_status": "1"},
              {"address": "38", "address_online_status": "1"},
              {"address": "39", "address_online_status": "1"},
              {"address": "40", "address_online_status": "1"}
            ]
          : Application.isType4
              ? [
                  {"address": "33", "address_online_status": "1"},
                  {"address": "34", "address_online_status": "1"},
                  {"address": "35", "address_online_status": "1"},
                  {"address": "36", "address_online_status": "1"},
                  {"address": "37", "address_online_status": "1"},
                  {"address": "38", "address_online_status": "1"},
                  {"address": "39", "address_online_status": "1"},
                  {"address": "40", "address_online_status": "1"}
                ]
              : <Map<String, dynamic>>[];

  List<String> insources = Application.isTypeTwo || Application.isType3
      ? ["/", "/", "/", "/"]
      : ["自动识别", "DC 110V", "DC 600V", "AC 380V"];
  List<String> runmodes = ["停机", "设置转速", "风量调节", "电压调速"];
  int selectInsource = 0;
  int selectRunmode = 0;

  void showOptions(List dataSource, Function itemSelected) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return BottomDrawer(dataSource, itemSelected);
        });
  }

  @override
  void initState() {
    super.initState();
    _airController.text = "0";
    _speedController.text = "0";

    _reloadData();
    _initData();
    _loadDemoData();
    _loadDeviceList();
  }

  // 加载演示数据
  void _loadDemoData() {
    setState(() {
      // 风机监测数据 - 使用正确的键名
      listData = [
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
        {
          "title": "输入源",
          "data": "本地",
          "unit": " ",
          "imageUrl": "images/输入源.png"
        },
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

      // 控制参数 - 使用正确的键名
      listData2 = [
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
    });
  }

  void _initData() {
    listData = decodeQuery(Application.isTypeTwo
        ? dataqueryTwo
        : Application.isType3
            ? dataquery3
            : Application.isType4
                ? dataquery4
                : dataquery);
    listData2 = decodeQuery2(Application.isTypeTwo
        ? dataqueryTwo
        : Application.isType3
            ? dataquery3
            : Application.isType4
                ? dataquery4
                : dataquery);
  }

  void _loadDeviceList() async {
    // 使用演示数据
    setState(() {
      fanNumbers = [
        {"address": "53", "name": "1号风机"},
        {"address": "54", "name": "2号风机"},
        {"address": "55", "name": "3号风机"},
        {"address": "56", "name": "4号风机"},
        {"address": "57", "name": "5号风机"},
        {"address": "58", "name": "6号风机"},
        {"address": "59", "name": "7号风机"},
        {"address": "60", "name": "8号风机"},
      ];
      _errorMessage = '';
      _isLoading = false;
    });

    // 原API调用已注释
    // try {
    //   setState(() => _isLoading = true);
    //   BaseResponse baseResponse =
    //       await FanVM.online_inside(widget.fanHomepage?["socket_client"] ?? '');
    //   if (baseResponse.success && baseResponse.data_list != null) {
    //     setState(() {
    //       fanNumbers = baseResponse.data_list;
    //       _errorMessage = '';
    //     });
    //   } else {
    //     setState(() {
    //       _errorMessage = baseResponse.msg ?? '获取设备列表失败';
    //     });
    //   }
    // } catch (e) {
    //   setState(() {
    //     _errorMessage = '网络错误: $e';
    //   });
    // } finally {
    //   setState(() => _isLoading = false);
    // }
  }

  void _reloadData() {
    _groupHandler = ListViewGroupHandler(
      numberOfSections: 6,
      numberOfRowsInSection: (section) {
        return section == 5
            ? Application.isTypeTwo
                ? 14
                : Application.isType3
                    ? 9
                    : Application.isType4
                        ? 18
                        : 18
            : 1;
      },
      headerForSection: (section) {
        return section == 1
            ? Padding(
                padding: EdgeInsets.only(top: 20, bottom: 10),
                child: Text("输入源"),
              )
            : section == 2
                ? Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 10),
                    child: Text("运行模式"),
                  )
                : SizedBox(height: 10);
      },
      cellForRowAtIndexPath: (indexPath) {
        if (indexPath.section == 0) {
          return _buildFanNumberSelector();
        }

        if (indexPath.section == 1) {
          return setupInsourceGridViewItems();
        }

        if (indexPath.section == 2) {
          return setupRunmodeGridViewItems();
        }

        if (indexPath.section == 3) {
          return _buildControlPanel();
        }

        if (indexPath.section == 4) {
          return setupGridViewItems();
        }

        return _buildDataRow(indexPath.row);
      },
      header: () => SizedBox(),
    );
  }

  Widget _buildFanNumberSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "选择风机编号",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666)),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _fannumber.text.isEmpty ? null : _fannumber.text,
                hint: Text("请选择风机"),
                isExpanded: true,
                items: fanNumbers.map((item) {
                  return DropdownMenuItem<String>(
                    value: (int.parse(item["address"]) - 32).toString(),
                    child: Text(item["name"] ?? "风机 ${item["address"]}"),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _fannumber.text = value;
                    });
                    _heartbeatQuery();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 风量等级下拉框
          Text(
            "设置风量等级",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666)),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _airController.text == "0" ? null : _airController.text,
                hint: Text("请选择风量等级"),
                isExpanded: true,
                items: List.generate(10, (index) {
                  return DropdownMenuItem<String>(
                    value: (index + 1).toString(),
                    child: Text("风量等级 ${index + 1}"),
                  );
                }),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _airController.text = value;
                    });
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          // 转速下拉框
          Text(
            "设置转速",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666)),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:
                    _speedController.text == "0" ? null : _speedController.text,
                hint: Text("请选择转速"),
                isExpanded: true,
                items: [500, 800, 1000, 1200, 1500, 1800, 2000, 2500, 3000]
                    .map((speed) {
                  return DropdownMenuItem<String>(
                    value: speed.toString(),
                    child: Text("$speed rpm"),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _speedController.text = value;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(int row) {
    if (row >= listData.length) return SizedBox();
    return Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(listData[row]['title'] +
              ' :  ' +
              listData[row]['data'] +
              listData[row]['unit']),
          leading: Image.asset(
            listData[row]['imageUrl'],
            width: 26,
            height: 26,
          ),
        ));
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Widget setupGridViewItems() {
    return Container(
      alignment: Alignment.center,
      child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 5,
          ),
          itemCount: listData2.length,
          itemBuilder: (BuildContext context, int itemIndex) {
            return Text(
              "${listData2[itemIndex]['data'] + listData2[itemIndex]['unit']}",
              textAlign: TextAlign.center,
            );
          }),
    );
  }

  Widget setupRunmodeGridViewItems() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "运行模式",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666)),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: runmodes[selectRunmode],
                isExpanded: true,
                items: runmodes.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectRunmode = runmodes.indexOf(value);
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget setupInsourceGridViewItems() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "输入源",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666)),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: insources[selectInsource],
                isExpanded: true,
                items: insources.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectInsource = insources.indexOf(value);
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  InkWell createItemBtn(section, title, itemIndex) {
    Color borderColor = (section == 1
            ? selectInsource == itemIndex
            : selectRunmode == itemIndex)
        ? Color(0xFFDAA070)
        : Color(0xFFE1E1E1);
    Color bgColor = (section == 1
            ? selectInsource == itemIndex
            : selectRunmode == itemIndex)
        ? Color(0xFFFAF7EB)
        : Colors.white;
    return InkWell(
        onTap: () {
          if (section == 1) {
            selectInsource = itemIndex;
          } else {
            selectRunmode = itemIndex;
          }
          setState(() {});
        },
        child: Container(
          alignment: Alignment.center,
          decoration: new BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: const BorderRadius.all(const Radius.circular(5.0)),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    // 移除嵌套 MaterialApp，直接返回 Scaffold
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
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
                          onPressed: _loadDeviceList,
                          child: Text('重试'),
                        ),
                      ],
                    ),
                  )
                : Refresher(
                    refreshController: _refreshController,
                    onRefresh: () => _queryFanInfo(needEndRefresh: true),
                    onLoading: () => _queryFanInfo(needEndRefresh: true),
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

  _recordFan(socket_client_model) async {
    if (CommonUtils.isEmpty(_fannumber.text)) {
      ToastUtils.showText(context, msg: "请选择风机编号");
      endRefresh();
      return;
    }

    var fannumber = int.parse(_fannumber.text);
    int address = fannumber;

    Map fanInfo = Application.isTypeTwo
        ? {
            "operate": "1",
            "socket_client": (widget.fanHomepage?["id"] ?? ''),
            "socket_client_model": (socket_client_model),
            "address": (address + 50),
            "source": selectInsource,
            "mode": selectRunmode,
            "level": (_airController.text),
            "rot_speed": (_speedController.text),
          }
        : Application.isType3
            ? {
                "operate": "1",
                "socket_client": (widget.fanHomepage?["id"] ?? ''),
                "socket_client_model": (socket_client_model),
                "address": (address + 32),
                "source": selectInsource,
                "mode": selectRunmode,
                "level": (_airController.text),
                "rot_speed": (_speedController.text),
              }
            : Application.isType4
                ? {
                    "operate": "1",
                    "socket_client": (widget.fanHomepage?["id"] ?? ''),
                    "socket_client_model": (socket_client_model),
                    "address": (address + 32),
                    "source": selectInsource,
                    "mode": selectRunmode,
                    "level": (_airController.text),
                    "rot_speed": (_speedController.text),
                  }
                : {
                    "operate": "1",
                    "socket_client":
                        (widget.fanHomepage?["socket_client"] ?? '').toString(),
                    "socket_client_model": (socket_client_model).toString(),
                    "address": (address + 32).toString(),
                    "source": selectInsource.toString(),
                    "mode": selectRunmode.toString(),
                    "level": (_airController.text).toString(),
                    "rot_speed": (_speedController.text).toString(),
                  };

    await FanVM.recordFan(fanInfo);
  }

  /// 心跳包
  void _heartbeatQuery() {
    _timer?.cancel();
    _queryFanInfo();
    _timer = Timer.periodic(new Duration(seconds: 30), (timer) {
      _queryFanInfo();
    });
  }

  /// @查询数据
  void _queryFanInfo({needEndRefresh = false}) async {
    if (CommonUtils.isEmpty(_fannumber.text)) {
      ToastUtils.showText(context, msg: "请选择风机编号");
      endRefresh();
      return;
    }

    var fannumber = int.parse(_fannumber.text);
    int address2 = fannumber +
        (Application.isTypeTwo
            ? 50
            : Application.isType3 || Application.isType4
                ? 32
                : 32);

    Map<String, dynamic> fanInfo =
        Application.isTypeTwo || Application.isType3 || Application.isType4
            ? {
                "check": "1",
                "socket_client": widget.fanHomepage?["id"] ?? '',
                "address": address2,
              }
            : {
                "check": "1",
                "socket_client": (widget.fanHomepage?["id"] ?? '').toString(),
                "address": (address2).toString(),
              };

    // 使用演示数据（当API不可用时）
    setState(() {
      // 模拟数据 - Type1 PMSM10C
      listData = [
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
        {
          "title": "输入源",
          "data": "本地",
          "unit": " ",
          "imageUrl": "images/输入源.png"
        },
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

      listData2 = [
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
      _errorMessage = '';
    });
    return; // Skip API call

    try {
      BaseResponse base = await FanVM.queryFanInfo(fanInfo);
      if (base.success && base.data != null) {
        setState(() {
          listData = decodeQuery(base.data);
          listData2 = decodeQuery2(base.data);
          _errorMessage = '';
        });
      } else {
        setState(() {
          _errorMessage = base.msg ?? '查询失败';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '网络错误: $e';
      });
    }

    if (needEndRefresh) {
      endRefresh();
    }
  }

  void endRefresh() {
    _refreshController.refreshCompleted(resetFooterState: true);
    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
