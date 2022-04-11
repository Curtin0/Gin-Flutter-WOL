import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_4/fan_controllers/version_update.dart';
import 'package:flutter_application_4/More/application.dart';
import '../components/common_utils.dart';
import 'fan_operation.dart';
import 'package:flutter_application_4/fan_controllers/fan_vm.dart';
import '../base/base.dart';
//import 'package:flutter_application_4/components/dialog.dart';
//import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:package_info/package_info.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../components/refresher.dart';
import 'package:flutter_application_4/components/list_view_group.dart';
import 'package:flutter_application_4/components/nodataview.dart';
import '../More/application.dart';

class FanHomepage {
  final String name;

  final String image;

  final String description;

  final String id;

  FanHomepage({this.name, this.image, this.description, this.id});
}

//风机编号列表页面
class FanlistNumber extends StatefulWidget {
  FanlistNumber({Key key, @required this.mt}) : super(key: key);

  final String mt;

  @override
  _FanlistNumberState createState() {
    return _FanlistNumberState();
  }
}

class _FanlistNumberState extends State<FanlistNumber> {
  List datalist = List();
  List datalist2 = [
    {
      "socket_client": "1",
      "online_status": "1",
      "name": "PMSM上位机",
      "description": "PMSM上位机",
      "id": "1",
    }
  ];
  List datalist3 = [
    {
      "socket_client": "1",
      "online_status": "1",
      "name": "PMSM上位机",
      "description": "PMSM上位机",
      "id": "1",
    }
  ];
  List datalist4 = [
    {
      "socket_client": "1",
      "online_status": "1",
      "name": "PMSM上位机",
      "description": "PMSM上位机",
      "id": "1",
    }
  ];

  getOnline() async {
    BaseResponse baseResponse = await FanVM.online();
    datalist = CommonUtils.isEmpty(baseResponse.data_list)
        ? List()
        : baseResponse.data_list;
    endRefresh();
    setState(() {});
  }

  // 版本更新
  updateVersion() async {
    // 测试
    checkVersionForUpdates("1.1.2");
    // 正式接口请对接放开
    BaseResponse baseResponse = await FanVM.version();
    checkVersionForUpdates(baseResponse.data["version"]);
  }

  // 版本更新检测
  checkVersionForUpdates(appVersion) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // 版本号是带小数点所以去除小数点用于做对比
    var targetVersion = appVersion.replaceAll('.', '');
    var currentVersion = packageInfo.version.replaceAll('.', '');
    if (int.parse(targetVersion) > int.parse(currentVersion)) {
      print("本地版本" + currentVersion);
      // 延时2s执行返回
      Future.delayed(Duration(seconds: 2), () {
        showDialog(
            context: context,
            builder: (ctx) {
              return VersionUpdate();
            });
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getOnline();
    _reloadData();
    updateVersion();
    super.initState();
  }

  ListViewGroupHandler _groupHandler;

  //每次刷新的时候调用
  void _reloadData() {
    _groupHandler = ListViewGroupHandler(
      ///@主页列表为4
      numberOfSections: 4,
      numberOfRowsInSection: (section) {
        return 1;
      },
      headerForSection: (section) {
        return Padding(
          padding: EdgeInsets.only(top: 20, bottom: 10),
          child: Text(section == 0
              ? "上位机PMSM10C"
              : section == 1
                  ? "上位机PMSM04E"
                  : section == 2
                      ? "上位机PMSM15"
                      : "上位机PMSM10A"),
        );
      },
      cellForRowAtIndexPath: (indexPath) {
        if (indexPath.section == 0) {
          return datalist.length > 0 ? setupListOne() : SizedBox();
        }
        if (indexPath.section == 1) {
          return setupListTwo();
        }
        if (indexPath.section == 2) {
          return setupList3();
        }
        return setupList4();
      },
      header: () {
        return SizedBox();
      },
    );
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Widget setupListOne() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 4.0, //纵轴距离
      crossAxisSpacing: 2.3, //横轴距离
      childAspectRatio: 1.3, //宽高比
      padding: EdgeInsets.all(8.0),
      children: datalist.asMap().keys.map<Widget>((index) {
        return _getGridViewItemUI(context, datalist[index]); //赋值后的Widget
      }).toList(),
    );
  }

  Widget setupListTwo() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 4.0, //纵轴距离
      crossAxisSpacing: 2.3, //横轴距离
      childAspectRatio: 1.3, //宽高比
      padding: EdgeInsets.all(8.0),
      children: datalist2.asMap().keys.map<Widget>((index) {
        return _getGridViewItemUI(context, datalist2[index],
            isTypeTwo: true); //赋值后的Widget
      }).toList(),
    );
  }

  Widget setupList3() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 4.0, //纵轴距离
      crossAxisSpacing: 2.3, //横轴距离
      childAspectRatio: 1.3, //宽高比
      padding: EdgeInsets.all(8.0),
      children: datalist3.asMap().keys.map<Widget>((index) {
        return _getGridViewItemUI(context, datalist3[index],
            isType3: true); //赋值后的Widget
      }).toList(),
    );
  }

  Widget setupList4() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 4.0, //纵轴距离
      crossAxisSpacing: 2.3, //横轴距离
      childAspectRatio: 1.3, //宽高比
      padding: EdgeInsets.all(8.0),
      children: datalist4.asMap().keys.map<Widget>((index) {
        return _getGridViewItemUI(context, datalist4[index],
            isType4: true); //赋值后的Widget
      }).toList(),
    );
  }

  endRefresh() {
    _refreshController.refreshCompleted(resetFooterState: true);
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fan',
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.only(left: 15, right: 15),
              color: Colors.white,
              child: Refresher(
                  refreshController: _refreshController,
                  onRefresh: () {
                    getOnline();
                  },
                  onLoading: () {
                    getOnline();
                  },
                  child: (datalist.length <= 0 &&
                          datalist2.length <= 0 &&
                          datalist3.length <= 0 &&
                          datalist4.length <= 0)
                      ? NoDataView("images/null_state08.png", "暂无设备")
                      : ListView.builder(
                          itemCount: _groupHandler.allItemCount,
                          itemBuilder: (context, index) {
                            return _groupHandler.cellAtIndex(index);
                          },
                        ))),
        ));
  }
}

Widget _getGridViewItemUI(BuildContext context, fanHomepage,
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
                    fanHomepage: fanHomepage,
                  )));
    },
    child: Card(
      elevation: 4.0,
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Image.asset(
                fanHomepage["online_status"] == "0"
                    ? "images/上位机连接-no.png"
                    : "images/上位机连接-yes.png",
                fit: BoxFit.cover,
              ),
              flex: 4,
            ),
            Expanded(
              child: Text(
                fanHomepage["name"],
                style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
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
  FanlistNumberControl({Key key, @required this.fanHomepage}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${fanHomepage["description"]}'),
      ),
      body: Center(
          child: Container(
              child: FanControl(mt: '风机控制', fanHomepage: fanHomepage))),
    );
  }
}
