package httpserver

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"webserver/src/config"
)

type httpserver struct {
	port int32
	serv *gin.Engine
}

var hs *httpserver = &httpserver{
	port: 8080,
	serv: nil,
}

func init() {
	hs.port = config.Conf.WebPort
	hs.serv = gin.Default()
	hs.serv.Static("/static", "./static")
	fmt.Printf("httpserver port:%v\n", hs.port)
}

func POST(relativePath string, handlers ...gin.HandlerFunc) {
	hs.serv.POST(relativePath, handlers...)
}

func DELETE(relativePath string, handlers ...gin.HandlerFunc) {
	hs.serv.DELETE(relativePath, handlers...)
}

func GET(relativePath string, handlers ...gin.HandlerFunc) {
	hs.serv.GET(relativePath, handlers...)
}

func PUT(relativePath string, handlers ...gin.HandlerFunc) {
	hs.serv.PUT(relativePath, handlers...)
}

func Run() {
	hs.serv.Run(fmt.Sprintf(":%d", hs.port))
}
