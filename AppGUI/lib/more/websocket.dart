////websocket封装
//
//import 'package:flutter/cupertino.dart';
//import 'package:web_socket_channel/io.dart';
//import 'package:web_socket_channel/web_socket_channel.dart';
//import 'package:event_bus/event_bus.dart';
//import 'package:flutter/foundation.dart';
//import 'dart:async';
//
//EventBus eventBus = EventBus();
//
//class SocketMessage {
//  WebSocketChannel channel;
//  // 创建WebSocketChannel 连接到WebSocket服务端
//  void initSocket() {
//    //print('初始化 websocket');
//    //channel = new IOWebSocketChannel.connect('ws://112.74.182.249:20020');
//    channel = IOWebSocketChannel.connect('ws://127.0.0.1:20020');
//    sendMessage();
//    channel.sink.add('');
//  }
//
//  // 将数据发送到服务器
//  void sendMessage() {
//    //print('重新连接');
//    return;
//    //channel.stream.listen(onData, onError: onError, onDone: onDone);
//  }
//
//  // socket 链接断开以后重新初始化 socket
//  void onDone() async {
//    debugPrint("Socket is closed");
//    initSocket();
//  }
//
//  // socket err 情况的处理
//  void onError(err) {
//    debugPrint(err.runtimeType.toString());
//    WebSocketChannelException ex = err;
//    debugPrint(ex.message);
//  }
//
//  // 收到服务端推送的消息event
//  void onData(event) {
//    print('收到消息：$event');
//    eventBus.fire(event);
//  }
//
//  // 关闭WebSocket连接
//  void dispose() {
//    print('关闭 websocket');
//    channel.sink.close();
//  }
//}
//
//enum StatusEnum { connect, connecting, close, closing }
//
//class WebsocketManager {
//  static WebsocketManager _singleton;
//
//  WebSocketChannel channel;
//  factory WebsocketManager() {
//    return _singleton;
//  }
//
//  StreamController<StatusEnum> socketStatusController =
//      StreamController<StatusEnum>();
//
//  WebsocketManager._();
//
//  static void init() async {
//    if (_singleton == null) {
//      _singleton = WebsocketManager._();
//      _singleton.connect();
//      _singleton.socketStatusController.stream.listen((state) {
//        _singleton.printStatus();
//      });
//    }
//  }
//
//  StatusEnum isConnect = StatusEnum.close; //默认为未连接
//  String _url = "ws://127.0.0.1:20020";
//
//  /// 发送消息
//  bool send(message) {
//    print("消息 ~~~ $message");
//    if (isConnect == StatusEnum.connect) {
//      print("消息发送 ~~~ $message");
//      channel.sink.add(message);
//      return true;
//    }
//    reconnect();
//    return false;
//  }
//
//  /// 连接
//  Future connect({String message}) async {
//    if (isConnect == StatusEnum.close) {
//      isConnect = StatusEnum.connecting;
//      socketStatusController.add(StatusEnum.connecting);
//      channel = await IOWebSocketChannel.connect(_url,
//          pingInterval: Duration(seconds: 5));
//      isConnect = StatusEnum.connect;
//      socketStatusController.add(StatusEnum.connect);
//      if (!isEmpty(message)) {
//        send(message);
//      }
//
//      return true;
//    }
//  }
//
//  /// 关闭连接
//  Future disconnect() async {
//    if (isConnect == StatusEnum.connect) {
//      isConnect = StatusEnum.closing;
//      socketStatusController.add(StatusEnum.closing);
//      await channel.sink.close(3000, "主动关闭");
//      isConnect = StatusEnum.close;
//      socketStatusController.add(StatusEnum.close);
//    }
//  }
//
//  /// 重连
//  reconnect({String message}) async {
//    await disconnect();
//    await connect(message: message);
//  }
//
//  // 状态监听
//  // void stateListen() {
//  //   print('重新连接');
//  //   return;
//
//  //   channel.stream.listen((event) {
//  //     print('收到消息：$event');
//  //     eventBus.fire(event);
//  //   }, onDone: () {
//  //     debugPrint("Socket is closed");
//  //     reconnect();
//  //   }, onError: (error) {
//  //     reconnect();
//  //     debugPrint(error.runtimeType.toString());
//  //     WebSocketChannelException ex = error;
//  //     debugPrint(ex.message);
//  //   });
//  // }
//
//  void printStatus() {
//    if (isConnect == StatusEnum.connect) {
//      print("websocket 已连接");
//    } else if (isConnect == StatusEnum.connecting) {
//      print("websocket 连接中");
//    } else if (isConnect == StatusEnum.close) {
//      print("websocket 已关闭");
//    } else if (isConnect == StatusEnum.closing) {
//      print("websocket 关闭中");
//    }
//  }
//
//  void dispose() {
//    socketStatusController.close();
//    socketStatusController = null;
//  }
//
//  static isEmpty(dynamic obj) {
//    return obj == null || obj == "";
//  }
//}
