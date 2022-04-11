import 'package:flutter/material.dart';

// @上拉抽屉

class BottomDrawer extends StatelessWidget {
  String title;
  String btnText;
  List items;
  Function callback;

  BottomDrawer(this.items, this.callback, {this.btnText, this.title = '请选择'});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        // height: MediaQuery.of(context).size.height * 0.7,
        // width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                  ),
                  Text(title,
                      style: TextStyle(fontSize: 15, color: Colors.black87)),
                  GestureDetector(
                    child: Icon(Icons.close),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
              Container(
                height: 280,
                child: ListView.builder(
                    itemBuilder: (ctx, i) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          callback?.call(i);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Text(
                                  '${(int.parse(items.elementAt(i)["address"]) - 32).toString()}'),
                              Spacer(),
                              Text(
                                '${items.elementAt(i)["address_online_status"] == "1" ? "在线" : "离线"}',
                                style: TextStyle(
                                    color: items.elementAt(
                                                i)["address_online_status"] ==
                                            "1"
                                        ? Colors.green
                                        : Colors.grey),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: items == null ? 0 : items.length),
              ),
              SizedBox(height: 10),
            ]));
  }
}
