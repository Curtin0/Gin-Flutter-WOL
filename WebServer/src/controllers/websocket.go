package controllers

import (
	"github.com/gin-gonic/gin"
	"log"
	"net/http"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	// 解决跨域问题
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func WebSocket(ctx *gin.Context) {
	ws, err := upgrader.Upgrade(ctx.Writer, ctx.Request, nil)
	if err != nil {
		log.Fatal(err)
		return
	}
	defer func() {
		ws.Close()
	}()

	for {
		dataType, data, err := ws.ReadMessage()
		if err != nil {
			return
		}

		ws.WriteMessage(dataType, data)
	}
}
