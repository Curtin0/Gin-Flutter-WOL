package net

import (
	"fmt"
	"net"
)

type NetServer struct {
	listener net.Listener
}

var GNet = &NetServer{

}

func (n *NetServer) Listen(port int32, accept func(conn net.Conn)) error {
	//建立socket端口监听
	var err error = nil
	n.listener, err = net.Listen("tcp", fmt.Sprintf(":%v", port))
	if err != nil {
		return err
	}
	fmt.Printf("tcp listen port:%v\n", port)

	fmt.Println("Waiting for clients ...")

	//等待客户端访问
	go func() {
		for {
			conn, err := n.listener.Accept() //Socket监听接收

			if err != nil {
				continue //如果发生错误，继续下一个循环。
			}

			fmt.Printf("%v tcp connect success\n", conn.RemoteAddr().String()) //tcp连接成功

			go accept(conn)
		}
	}()
	return nil
}