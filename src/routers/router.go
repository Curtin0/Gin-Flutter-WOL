package routers

import (
	"webserver/src/controllers"
	"webserver/src/httpserver"
)

func init() {
	basepath := "/api/v1"

	httpserver.GET(basepath+"/websocket", controllers.WebSocket)

	httpserver.POST("/record", controllers.Operate)
	httpserver.POST("/query", controllers.Query)
	httpserver.POST("/online", controllers.DeviceOnline) // 查询在线状态
	httpserver.POST("/online_inside", controllers.SubDeviceOnline)
	httpserver.GET("/download/:filename", controllers.Download)
	httpserver.POST("/version", controllers.Version)
}
