package main

//Socket客户端 -> Socket服务端 -> event消息订阅、监听、发布 -> WebSocket服务端 -> Websocket客户端
//Socket server端口 "localhost:20019"
//Websocket server端口 "localhost:8080"

import (
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/websocket"
	"github.com/jageros/eventhub"
)

//主函数
func main() {
	//添加端口绑定 否则只能在本地和客户端连接

	//建立socket端口监听
	netListen, err := net.Listen("tcp", "localhost:20019")
	CheckError(err)

	defer netListen.Close()

	//日志功能，服务端能看到在运行
	Log("Waiting for clients ...")

	//等待客户端访问
	for {
		conn, err := netListen.Accept() //Socket监听接收
		//go WebsocketServer()            //★启动Websocket服务
		if err != nil {
			continue //如果发生错误，继续下一个循环。
		}
		//go handleClient(conn) //多并发处理

		Log(conn.RemoteAddr().String(), "tcp connect success") //tcp连接成功

		//处理连接任务 接收客户端信息和反馈给客户端信息
		go handleConnection(conn)
	}
}

//HandleClient 可以接受多个请求 不调用
// func handleClient(conn net.Conn) {
// 	defer conn.Close()
// 	daytime := time.Now().String()
// 	// don't care about return value
// 	conn.Write([]byte(daytime))
// 	// we're finished with this client
// }

//处理连接 来自主函数
func handleConnection(conn net.Conn) {
	buffer := make([]byte, 2048) //建立一个slice
	for {
		n, err := conn.Read(buffer) //读取客户端传来的内容 buffer缓冲器包含读写操作

		go WebsocketServer() //★启动Websocket服务

		if err != nil {
			Log(conn.RemoteAddr().String(), "connection error: ", err)
			return //当远程客户端连接发生错误（断开）后，终止此协程。
		}

		Log(conn.RemoteAddr().String(), "receive data string:\n", string(buffer[:n]))

		//返回给客户端的信息
		strTemp := "SocketServer has got msg \"" + string(buffer[:n]) + "\" at " + time.Now().String()

		conn.Write([]byte(strTemp))

		Event() //★启动监听服务  监听来自Socket客户端（存入buffer的）发来的数据 暂无法使用

	}
}

//日志处理
func Log(v ...interface{}) {
	log.Println(v...)
}

//错误处理
func CheckError(err error) {
	if err != nil {
		fmt.Fprintf(os.Stderr, "Fatal error: %s", err.Error())
	}
}

/****************************************************************************
//
//以下为Websocket服务
//
****************************************************************************/

// 需要定义一个升级
// 用buffer读写数据
var upGrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

//Websocket主函数
func WebsocketServer() {
	fmt.Println("starting Websocket server...")
	setupRoutes()
	log.Fatal(http.ListenAndServe(":8080", nil))
}

//主函数处理
func setupRoutes() {
	http.HandleFunc("/ws", wsEndpoint)
}

//详细处理部分
func wsEndpoint(w http.ResponseWriter, r *http.Request) {
	// http升级为Websocket连接
	// connection
	ws, err := upGrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
	}

	// say hello to Web
	log.Println("WebsocketClient Connected")
	err = ws.WriteMessage(1, []byte("Hello WebsocketClient!"))

	//转换JSON格式
	/*
		type DataGroup struct {
			//ID   int
			Data string `json:"data"`
			//Colors []string
		}
		group := DataGroup{
			//ID:   1,
			Data: "['2', '0','2', '1000', '40', '110', '3000', '3000', '3000','20000', '1.23']",
			//Colors: []string{"['2', '0','2', '1000', '40', '110', '3000', '3000', '3000','20000', '1.23']"},
		}
		b, err := json.Marshal(group)
		if err != nil {
			fmt.Println("error:", err)
		}
		os.Stdout.Write(b)
	*/

	// 发送消息处理
	go func() {
		for {
			time.Sleep(time.Second * 15)
			err = ws.WriteMessage(1, []byte(time.Now().Format("2006-01-02 15:04:05")))
			err = ws.WriteMessage(1, []byte("strTemp"))

			if err != nil {
				log.Println(err)
			}
		}
	}()

	// 创建Websocket连接
	go func(conn *websocket.Conn) {
		for {
			// 读取一条信息
			messageType, p, err := conn.ReadMessage()
			if err != nil {
				log.Println(err)
				return
			}
			// 打印日志
			log.Println(string(p))

			if err := conn.WriteMessage(messageType, p); err != nil {
				log.Println(err)
				return
			}
		}
	}(ws)
}

/****************************************************************************
**
**以下为Event监听事件服务
**监听来自Socket服务端的消息  传递给Websocket服务端输出
**作者源码使用解释 https://blog.csdn.net/lhj_168/article/details/103394237
**
****************************************************************************/

func Event() {
	//监听事件
	// eventhub.Subscribe(2, func(args ...interface{}) {
	// 	fmt.Printf("Subscribe1 eventId=2 args=%v\n", args)
	// })
	// eventhub.Subscribe(1, func(args ...interface{}) {
	// 	fmt.Printf("Subscribe2 eventId=1 args=%v\n", args)
	// })
	eventhub.Subscribe(3, func(args ...interface{}) {
		fmt.Printf("Subscribe3 eventId=3 args=%v\n", args)
		if arg, ok := args[0].(func()); ok {
			arg()
		}
	})

	// 监听并取消监听
	// seq := eventhub.Subscribe(1, func(args ...interface{}) {
	// 	fmt.Printf("Subscribe4 eventId=1 args=%+v\n", args)
	// })
	// eventhub.Unsubscribe(1, seq)

	// 发布事件
	//eventhub.Publish(1, 10, 100)
	//eventhub.Publish(2, 20, 200)
	eventhub.Publish(3, readevent)
}

// 此函数用作参数
func readevent() {
	fmt.Printf("waitting\n")
}
