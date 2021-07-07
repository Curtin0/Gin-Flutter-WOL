package main

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
		go WebsocketServer()            //调用Websocket主函数
		if err != nil {
			continue //如果发生错误，继续下一个循环。
		}
		//go handleClient(conn) //多并发处理

		Log(conn.RemoteAddr().String(), "tcp connect success") //tcp连接成功

		//处理连接任务 接收客户端信息和反馈给客户端信息
		go handleConnection(conn)
	}
}

//HandleClient 可以接受多个请求 目前有问题
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
		n, err := conn.Read(buffer) //读取客户端传来的内容 buffer缓冲器 包含读写操作

		if err != nil {
			Log(conn.RemoteAddr().String(), "connection error: ", err)
			return //当远程客户端连接发生错误（断开）后，终止此协程。
		}

		Log(conn.RemoteAddr().String(), "receive data string:\n", string(buffer[:n]))

		//返回给客户端的信息
		strTemp := "CofoxServer got msg \"" + string(buffer[:n]) + "\" at " + time.Now().String()
		conn.Write([]byte(strTemp))

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

// We'll need to define an UpGrader
// this will require a Read and Write buffer size
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
	// upgrade this connection to a WebSocket
	// connection
	ws, err := upGrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println(err)
	}

	// say hello to Web
	log.Println("WebClient Connected")
	err = ws.WriteMessage(1, []byte("Hello Client!"))
	//err = ws.WriteMessage([]byte(strTemp)) //问题

	//转换JSO  N格式
	/*
		type DataGroup struct {
			//ID   int
			Data string `json:"data"`
			//Colors []string
			//note   string
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

	// handle writer
	go func() {
		for {
			time.Sleep(time.Second * 5)
			err = ws.WriteMessage(1, []byte(time.Now().Format("2006-01-02 15:04:05")))
			if err != nil {
				log.Println(err)
			}
		}
	}()

	// listen indefinitely for new messages coming
	// through on our WebSocket connection
	go func(conn *websocket.Conn) {
		for {
			// read in a message
			messageType, p, err := conn.ReadMessage()
			if err != nil {
				log.Println(err)
				return
			}
			// print out that message for clarity
			log.Println(string(p))

			if err := conn.WriteMessage(messageType, p); err != nil {
				log.Println(err)
				return
			}
		}
	}(ws)
}
