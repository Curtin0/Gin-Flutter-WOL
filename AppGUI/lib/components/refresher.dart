import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Refresher extends StatelessWidget {
  Refresher({
    Key key,
    this.refreshController,
    this.child,
    this.onRefresh,
    this.onLoading,
    this.loadingColor = Colors.black54,
  }) : super(key: key);

  final RefreshController refreshController;

  final Widget child;
  final onRefresh;
  final onLoading;
  final Color loadingColor;

  Widget loading = Image.asset("images/xl_loading.gif",width:24 ,height: 24,);
  @override
  Widget build(BuildContext context) {
    return RefreshConfiguration(
      shouldFooterFollowWhenNotFull: (mode) {
        return mode == LoadStatus.noMore ? true : false;
      },
      headerTriggerDistance:15,
      footerTriggerDistance: MediaQuery.of(context).size.height * 0.2 > 200
          ? MediaQuery.of(context).size.height * 0.2
          : 200,
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: ClassicHeader(
          height: 45.0,
          textStyle:TextStyle(fontSize: 14, color: Color(0xFF999999)),
          refreshingIcon: Image.asset("images/xl_loading.gif",width:24 ,height: 24,color: loadingColor,),
          idleIcon:Image.asset("images/loading_idle.png",width:24 ,height: 24,color: loadingColor,),
          releaseIcon:Image.asset("images/xl_loading.gif",width:24 ,height: 24,color: loadingColor,),
          completeIcon: null,
          releaseText: '',
          refreshingText: '',
          completeText: '刷新完成',
          failedText: '刷新失败',
          idleText: '',
        ),

        // ClassicFooter、CustomFooter、LinkFooter、LoadIndicator
        footer: ClassicFooter(
            textStyle:TextStyle(fontSize: 16, color: Color(0xFF999999)),
            loadingText: "正在加载…",
            noDataText: "",
            canLoadingText: "松手,加载更多!",
            idleText: "上拉加载更多",
            failedText: "加载失败！点击重试！"),
        controller: refreshController,
        onRefresh: onRefresh,
        onLoading: onLoading,
        child: child,
      ),
    );
  }
}
