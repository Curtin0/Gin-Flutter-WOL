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
import 'dart:async';
import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class FanControl extends StatefulWidget {
  FanControl({Key key, @required this.mt, this.fanHomepage}) : super(key: key);
  final Map fanHomepage;

  final String mt;

  @override
  _FanControlState createState() {
    return new _FanControlState();
  }
}

class _FanControlState extends State<FanControl> {
  @override
  Widget build(BuildContext context) {
    final title = 'http';
    return new MaterialApp(
      title: title,
      home: new MyHomePage(
        title: title,
        fanHomepage: widget.fanHomepage,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final Map fanHomepage;

  MyHomePage({Key key, @required this.title, this.fanHomepage})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _fannumber = TextEditingController();
  TextEditingController _airController = TextEditingController();
  TextEditingController _speedController = TextEditingController();
  ListViewGroupHandler _groupHandler;
  List listData = [];
  List listData2 = [];
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
              : List();

  //10C和10A型号有输入源  15和04E型号无输入源
  List<String> insources = Application.isTypeTwo || Application.isType3
      ? ["/", "/", "/", "/"]
      : ["自动识别", "DC 110V", "DC 600V", "AC 380V"];
  List<String> runmodes = ["停机", "设置转速", "风量调节", "电压调速"];
  int selectInsource = 0;
  int selectRunmode = 0;

  /// 弹出选项
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
    print("initState");
    _airController.text = "0";
    _speedController.text = "0";

    _reloadData();
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

    //监听广播
    eventBus.on<Map>().listen((event) {
      //用来监听读取服务器数据
      listData = decodeQuery(event);
      listData2 = decodeQuery2(event);
      setState(() {});
    });

    //★
    //2 3 4类型的上位机不包含此接口
    // if (!Application.isTypeTwo ||
    //     !Application.isType3 ||
    //     !Application.isType4) {
    if (!Application.isTypeTwo & !Application.isType3 & !Application.isType4) {
      onlineInside();
    }
  }

  onlineInside() async {
    BaseResponse baseResponse =
        await FanVM.online_inside(widget.fanHomepage["socket_client"]);
    fanNumbers = baseResponse.data_list;
    setState(() {});
  }

  //每次刷新的时候调用
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
                : SizedBox(
                    height: 10,
                  );
      },
      cellForRowAtIndexPath: (indexPath) {
        if (indexPath.section == 0) {
          return Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                textDirection: TextDirection.ltr,
                children: <Widget>[
                  Theme(
                    data: new ThemeData(primaryColor: Colors.black),
                    child: TextFormField(
                      controller: _fannumber,
                      decoration: InputDecoration(
                          labelText: "选择风机编号",
                          hintText: "选择21~28(以从站地址标识)",
                          icon: Icon(Icons.edit)),
                      cursorColor: Colors.black,
                      //光标颜色
                      validator: (v) {
                        return v.trim().length > 0 ? null : "选择正确的编号";
                      },
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        showOptions(fanNumbers, (i) {
                          _fannumber.text =
                              (int.parse(fanNumbers[i]["address"]) - 32)
                                  .toString();
//                          sendQueryDataMessage();
                          _heartbeatQuery();
                        });
                      },
                    ),
                  ),
                ],
              ));
        }

        if (indexPath.section == 1) {
          return setupInsourceGridViewItems();
        }

        if (indexPath.section == 2) {
          return setupRunmodeGridViewItems();
        }

        if (indexPath.section == 3) {
          return Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                textDirection: TextDirection.ltr,
                children: <Widget>[
                  Theme(
                    data: new ThemeData(primaryColor: Colors.black),
                    child: TextFormField(
                        autofocus: true,
                        controller: _airController,
                        decoration: InputDecoration(
                            labelText: "设置风量等级",
                            hintText: "输入风量等级",
                            icon: Icon(Icons.reorder)),
                        cursorColor: Colors.black,
                        validator: (v) {
                          return v.trim().length > 0 ? null : "输入正确的风量等级";
                        }),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Theme(
                    data: new ThemeData(primaryColor: Colors.black),
                    child: TextFormField(
                        autofocus: true,
                        controller: _speedController,
                        decoration: InputDecoration(
                            labelText: "设置转速",
                            hintText: "输入转速",
                            icon: Icon(Icons.toys)),
                        cursorColor: Colors.black,
                        validator: (v) {
                          return v.trim().length > 0 ? null : "输入正确的转速";
                        }),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        child: Padding(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: Text("手动模式")),
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all(Colors.blueGrey),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                        ),
                        onPressed: () {
                          _recordFan("1");
                        },
                      ),
                      OutlinedButton(
                        child: Padding(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: Text("自动模式"),
                        ),
                        style: ButtonStyle(
                            foregroundColor:
                                MaterialStateProperty.all(Colors.blueGrey),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white)),
                        onPressed: () {
                          _recordFan("0");
                        },
                      ),
                    ],
                  )
                ],
              ));
        }

        if (indexPath.section == 4) {
          return setupGridViewItems();
        }

        return Container(
            alignment: Alignment.center,
            color: Colors.white,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(listData[indexPath.row]['title'] +
                  ' :  ' +
                  listData[indexPath.row]['data'] +
                  listData[indexPath.row]['unit']),
              //data来自服务器
              leading: Image.asset(
                listData[indexPath.row]['imageUrl'],
                width: 26,
                height: 26,
              ),
            ));
      },
      header: () {
        return SizedBox();
      },
    );
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  /// 数据源
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

  /// 运行模式
  Widget setupRunmodeGridViewItems() {
    return Container(
      alignment: Alignment.center,
      child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 5,
          ),
          itemCount: runmodes.length,
          itemBuilder: (BuildContext context, int itemIndex) {
            return createItemBtn(2, runmodes[itemIndex], itemIndex);
          }),
    );
  }

  Widget setupInsourceGridViewItems() {
    return Container(
      alignment: Alignment.center,
      child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 5,
          ),
          itemCount: insources.length,
          itemBuilder: (BuildContext context, int itemIndex) {
            return createItemBtn(1, insources[itemIndex], itemIndex);
          }),
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
    return MaterialApp(
        title: 'operation',
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                color: Colors.white,
                child: Refresher(
                    refreshController: _refreshController,
                    onRefresh: () {
                      _queryFanInfo(needEndRefesh: true);
                    },
                    onLoading: () {
                      _queryFanInfo(needEndRefesh: true);
                    },
                    child: ListView.builder(
                      itemCount: _groupHandler.allItemCount,
                      itemBuilder: (context, index) {
                        return _groupHandler.cellAtIndex(index);
                      },
                    )))));
  }

  /// 发送数据到服务器
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
            "socket_client": (widget.fanHomepage["id"]),
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
                "socket_client": (widget.fanHomepage["id"]),
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
                    "socket_client": (widget.fanHomepage["id"]),
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
                        (widget.fanHomepage["socket_client"]).toString(),
                    "socket_client_model": (socket_client_model).toString(),
                    "address": (address + 32).toString(),
                    "source": selectInsource.toString(),
                    "mode": selectRunmode.toString(),
                    "level": (_airController.text).toString(),
                    "rot_speed": (_speedController.text).toString(),
                  };

    await FanVM.recordFan(fanInfo);
  }

  Timer _timer;

  /// 心跳包
  _heartbeatQuery() {
    if (!CommonUtils.isEmpty(_timer)) {
      _timer.cancel();
      _timer = null;
    }
    _queryFanInfo();
    _timer = Timer.periodic(new Duration(seconds: 30), (timer) {
      _queryFanInfo();
    });
  }

  /// @查询数据
  _queryFanInfo({needEndRefesh = false}) async {
    if (CommonUtils.isEmpty(_fannumber.text)) {
      ToastUtils.showText(context, msg: "请选择风机编号");
      endRefresh();
      return;
    }

    var fannumber = int.parse(_fannumber.text);
    int address2 = fannumber +
        (Application.isTypeTwo
            ? 50
            : Application.isType3
                ? 32
                : Application.isType4
                    ? 32
                    : 32);

    ///@类型二、三、四上位机此接口处为int类型，类型一上位机为string类型
    Map<String, dynamic> fanInfo =
        Application.isTypeTwo || Application.isType3 || Application.isType4
            ? {
                "check": "1",
                "socket_client": widget.fanHomepage["id"],
                "address": address2,
              }
            : {
                "check": "1",
                "socket_client": (widget.fanHomepage["id"]).toString(),
                "address": (address2).toString(),
              };

    BaseResponse base = await FanVM.queryFanInfo(fanInfo);
    eventBus.fire(base.data);
    if (needEndRefesh) {
      endRefresh();
    }
  }

  endRefresh() {
    _refreshController.refreshCompleted(resetFooterState: true);
    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer = null;
    super.dispose();
  }
}
