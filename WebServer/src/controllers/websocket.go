package controllers

import (
	"encoding/json"
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

type WSClient struct {
	conn      *websocket.Conn
	send      chan []byte
	deviceID  int32
	createdAt time.Time
}

type WSBroadcastPayload struct {
	Type    string      `json:"type"`    // "device_update", "keepalive", "error"
	DeviceID int32       `json:"device_id"`
	Address  int32       `json:"address"`
	Data     interface{} `json:"data,omitempty"`
}

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

var (
	wsClients = make(map[*WSClient]bool)
	wsMutex   sync.RWMutex
)

// WebSocket 处理 - 接收Flutter客户端连接
func WebSocket(ctx *gin.Context) {
	ws, err := upgrader.Upgrade(ctx.Writer, ctx.Request, nil)
	if err != nil {
		return
	}

	client := &WSClient{
		conn:      ws,
		send:      make(chan []byte, 256),
		createdAt: time.Now(),
	}

	wsMutex.Lock()
	wsClients[client] = true
	wsMutex.Unlock()

	defer func() {
		wsMutex.Lock()
		delete(wsClients, client)
		wsMutex.Unlock()
		ws.Close()
	}()

	// 启动写线程
	go client.writePump()

	// 监听读线程（检测客户端断开）
	client.readPump()
}

// 推送设备数据到所有WebSocket客户端
func BroadcastDeviceUpdate(deviceID, address int32, data interface{}) {
	payload := WSBroadcastPayload{
		Type:    "device_update",
		DeviceID: deviceID,
		Address:  address,
		Data:     data,
	}

	msg, err := json.Marshal(payload)
	if err != nil {
		return
	}

	wsMutex.RLock()
	defer wsMutex.RUnlock()

	for client := range wsClients {
		select {
		case client.send <- msg:
		default:
			// 客户端缓冲区满，跳过
		}
	}
}

// 推送错误信息到所有WebSocket客户端
func BroadcastError(deviceID int32, errMsg string) {
	payload := WSBroadcastPayload{
		Type:    "error",
		DeviceID: deviceID,
		Data: map[string]string{
			"message": errMsg,
		},
	}

	msg, err := json.Marshal(payload)
	if err != nil {
		return
	}

	wsMutex.RLock()
	defer wsMutex.RUnlock()

	for client := range wsClients {
		select {
		case client.send <- msg:
		default:
		}
	}
}

// 广播心跳保活
func BroadcastKeepalive() {
	payload := WSBroadcastPayload{
		Type: "keepalive",
		Data: map[string]int64{
			"timestamp": time.Now().Unix(),
		},
	}

	msg, err := json.Marshal(payload)
	if err != nil {
		return
	}

	wsMutex.RLock()
	defer wsMutex.RUnlock()

	for client := range wsClients {
		select {
		case client.send <- msg:
		default:
		}
	}
}

func (c *WSClient) readPump() {
	defer func() {
		wsMutex.Lock()
		delete(wsClients, c)
		wsMutex.Unlock()
		c.conn.Close()
	}()

	c.conn.SetReadLimit(512)
	c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		return nil
	})

	for {
		_, _, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
				// 非正常关闭
			}
			break
		}
	}
}

func (c *WSClient) writePump() {
	ticker := time.NewTicker(30 * time.Second)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if !ok {
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			// 批量写入
			n := len(c.send)
			for i := 0; i < n; i++ {
				w.Write([]byte{'\n'})
				w.Write(<-c.send)
			}

			if err := w.Close(); err != nil {
				return
			}
		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}