import 'package:flutter/material.dart';

class DeviceDataPage extends StatefulWidget {
  const DeviceDataPage({Key? key}) : super(key: key);

  @override
  _DeviceDataPageState createState() => _DeviceDataPageState();
}

class _DeviceDataPageState extends State<DeviceDataPage> {
  // 默认静态数据
  final List listData = [
    {
      "title": 'U相电流',
      "data": '0.00',
      "unit": ' A',
      "imageUrl": 'images/电流.png',
    },
    {
      "title": 'V相电流',
      "data": '0.00',
      "unit": ' A',
      "imageUrl": 'images/电流.png',
    },
    {
      "title": 'W相电流',
      "data": '0.00',
      "unit": ' A',
      "imageUrl": 'images/电流.png',
    },
    {
      "title": 'U相电流有效值',
      "data": '0.00',
      "unit": ' A',
      "imageUrl": 'images/电流2.png',
    },
    {
      "title": 'V相电流有效值',
      "data": '0.00',
      "unit": ' A',
      "imageUrl": 'images/电流2.png',
    },
    {
      "title": 'W相电流有效值',
      "data": '0.00',
      "unit": ' A',
      "imageUrl": 'images/电流2.png',
    },
    {
      "title": 'X轴振动加速度',
      "data": '0.00',
      "unit": ' g',
      "imageUrl": 'images/x轴加速度.png',
    },
    {
      "title": 'Y轴振动加速度',
      "data": '0.00',
      "unit": ' g',
      "imageUrl": 'images/y轴加速度.png',
    },
    {
      "title": 'Z轴振动加速度',
      "data": '0.00',
      "unit": ' g',
      "imageUrl": 'images/z轴加速度.png',
    },
    {
      "title": '加速度矢量和',
      "data": '0.00',
      "unit": ' g',
      "imageUrl": 'images/振动加速度.png',
    },
    {
      "title": '温度',
      "data": '0',
      "unit": ' ℃',
      "imageUrl": 'images/温度.png',
    },
    {
      "title": '数据刷新时间',
      "data": '0',
      "unit": '',
      "imageUrl": 'images/time.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 250.0,
            backgroundColor: const Color(0xFF007AFF),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '设备实时数据',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Image.asset(
                "images/tongye2pro.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 60.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.cyan[100 * ((index) % 11)],
                  child: ListTile(
                    title: Text(
                      listData[index]['title'] +
                          ' :  ' +
                          listData[index]['data'].toString() +
                          listData[index]['unit'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    leading: Image.asset(
                      listData[index]['imageUrl'].toString(),
                      width: 30,
                      height: 30,
                    ),
                  ),
                );
              },
              childCount: listData.length,
            ),
          ),
        ],
      ),
    );
  }
}
