# Socket-to-WebSocket

The framework is a cloud server backgrounder that emits data received by the Socket server side through the WebSocket server side

Web pages for testing are already given in the file, and you only need to align your front-end interface Websocket's ip and listening ports with the program when you actually use them.

The author will then refine the Socket client with serial communication conversion, which enables a Demo of the Internet of Things.

Enable controllers with RS232/485 interfaces to be uploaded to a cloud server via a PC device for computing and storage, pushing the results to the front end, and any interface program that uses the Websocket protocol, such as your app, web or desktop app, can be used.

Anyone interested in this framework can contact the author by email to exchange pengfei.fu@outlook.com


该框架为一个云服务器后台程序，可以将Socket服务端收到的数据通过WebSocket服务端发出

文件中已经给出了用于测试的Web页面，实际使用时只需要将自己的前端界面Websocket的ip和监听端口和本程序中保持一致即可。

作者后续会完善加上串口通信转换Socket客户端，（该功能在作者的主页已经用Python实现了，但是Go语言版本还需要一段时间）这样可实现一个设备联网的Demo，在此基础上你可以添加通信协议解析进行使用。

使得具有RS232/485接口的控制器可以通过PC设备上传到云服务器进行计算、存储，将结果推送给前端，运行在App、Web或者桌面应用等任何使用了Websocket协议的界面程序。

如果任何人对这个框架感兴趣，可以邮件联系作者交流 pengfei.fu@outlook.com
![strucyure](https://user-images.githubusercontent.com/49359900/124684592-14fd3800-df02-11eb-85b5-1319f782e406.png)
![绘图3](https://user-images.githubusercontent.com/49359900/124928355-1cbbfa00-e032-11eb-9596-e4a60edaee9e.png)
