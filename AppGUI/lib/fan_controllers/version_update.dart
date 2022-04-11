import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:flutter_application_4/components/jytoast.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class VersionUpdate extends StatefulWidget {
  VersionUpdate({Key key}) : super(key: key);

  @override
  _VersionUpdateState createState() => _VersionUpdateState();
}

class _VersionUpdateState extends State<VersionUpdate> {
  String vInfo = '';
  String progress = "立即更新";

  // 更新弹窗
  Widget popupUpdate() {
    return Container(
      padding: EdgeInsets.all(40),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5))),
      child: Stack(children: <Widget>[
        Container(
          child: Image.asset("images/updateBg.png"),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          SizedBox(height: 120),
          Row(
            children: [
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("发现新版本",
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                  SizedBox(height: 10),
                  Text("V1.1.4",
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                  SizedBox(height: 50),
                ],
              ),
              SizedBox(
                width: 50,
              )
            ],
          ),
          Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      updateVersion(context);
                    },
                    child: Container(
                        width: double.infinity,
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.all(Radius.circular(45 / 2)),
                          gradient: LinearGradient(
                            colors: <Color>[
                              Color(0xFF179DFE),
                              Color(0xFF0C75FF)
                            ],
                          ),
                        ),
                        child: Text(progress)),
                  ),
                  SizedBox(height: 24),
                ],
              )),
        ])
      ]),
    );
  }

  var loadingHide;

  // 版本更新
  void updateVersion(loadingContext) async {
    if (Platform.isAndroid) {
      loadingHide = ToastUtils.showLoadingText(loadingContext, msg: "下载中...");
      String url = "http://112.74.182.249/download/android_1.1.4.apk";
      try {
        // destinationFilename 是对下载的apk进行重命名,可以自己定义
        OtaUpdate()
            .execute(url, destinationFilename: 'newsHappyzebra.apk')
            .listen(
          (OtaEvent event) {
            print('更新 status:${event.status},value:${event.value}');
            switch (event.status) {
              case OtaStatus.DOWNLOADING:
                {
                  progress = '下载进度:${event.value}%'; // 下载中
                  setState(() {});
                  print(progress);
                }
                break;
              case OtaStatus.INSTALLING: //安装中
                print('安装中...');
                setState(() {
                  progress = '安装中...';
                });
                loadingHide();
                Future.delayed(Duration(milliseconds: 3000), () {
                  setState(() {
                    progress = "立即更新";
                  });
                });
                break;
              case OtaStatus.PERMISSION_NOT_GRANTED_ERROR: // 权限错误
                {
                  print('更新失败，请稍后再试');
                  resetProgress();
                }
                break;
              default:
                {
                  // 其他问题
                  resetProgress();
                }
                break;
            }
          },
        );
      } catch (e) {
        print('更新失败，请稍后再试');
        resetProgress();
      }
    }
  }

  void resetProgress() {
    loadingHide();
    setState(() {
      progress = "立即更新";
    });
    ToastUtils.showError(context, msg: "更新失败，请稍后再试");
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [popupUpdate()],
    );
  }
}
