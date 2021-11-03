package controllers

import (
	"fmt"
	"net"
	"time"
	"webserver/src/models"
)

const (
	FuncCodeKeepalive  int32 = 0x0E // 心跳功能码
	FuncCodeInitialize int32 = 0x0F // 初始化功能码
	FuncCodeUpparam    int32 = 0x41 // 上传参数
	FuncCodeDistribute int32 = 0x0D // 分配id
)

// 发送数据
func senddata(op OperateInfo, conn net.Conn) {
	models.AddOperateRecord(&models.OperateRecord{
		DeviceID:    op.SocketClient,
		DeviceModel: op.SocketClientModel,
		Address:     op.Address,
		Source:      op.Source,
		Mode:        op.Mode,
		Level:       op.Level,
		RotSpeed:    op.RotSpeed,
		Time:        time.Now().Local(),
	})
	protocol := models.RS485SingleFrameProtocol{
		DeviceID:      op.SocketClient,
		DeviceModel:   op.SocketClientModel,
		Address:       op.Address,
		FuncCode:      0x41,
		MainVersion:   0x01,
		BranchVersion: 0,
		Type:          1,
		Data: &models.OutParam{
			Source:   op.Source,
			Mode:     op.Mode,
			Level:    op.Level,
			RotSpeed: op.RotSpeed,
		},
	}
	data := serialize(&protocol)
	if data != nil {
		conn.Write(data)
	} else {
		fmt.Printf("serialize error")
	}
}

func accept(conn net.Conn) {
	var deviceinfo *DeviceInfo = nil
	defer func() {
		conn.Close()
		if deviceinfo != nil {
			DelDevice(deviceinfo.deviceid)
		}
	}()

	buffer := make([]byte, 2048) //建立一个切片
	var remain int = 0

	for {
		n, err := conn.Read(buffer[remain:]) //读取客户端传来的内容 buffer缓冲器包含读写操作

		if err != nil {
			fmt.Printf("%v connection error: %v\n", conn.RemoteAddr().String(), err)
			return //当远程客户端连接发生错误（断开）后，终止此协程。
		}
		protocol := models.RS485SingleFrameProtocol{}
		len := deserialize(buffer[:n], &protocol)
		if len > 0 {
			remain = n - len
			if remain > 0 {
				_ = append(buffer[:0], buffer[:len]...)
			}
			fmt.Println(protocol)

		} else if len == 0 {
			remain = n
			continue
		} else {
			remain = 0
			continue
		}
		fmt.Printf("%v receive data string:%v\n", conn.RemoteAddr().String(), string(buffer[:n]))
		if protocol.FuncCode == FuncCodeKeepalive {
			handleKeepalive(&protocol)
		} else if protocol.FuncCode == FuncCodeDistribute {
			if deviceinfo == nil {
				// 创建设备对象
				deviceinfo = &DeviceInfo{
					deviceid:          DeviceMng.addDeviceID(),
					conn:              conn,
					status:            1,
					lastKeepaliveTime: time.Now().Unix(),
					subDeviceMap:      make(map[int32]*SubDeviceInfo),
				}
				//deviceinfo.subDeviceMap[protocol.Address] = &SubDeviceInfo{
				//	device: &models.Device{
				//		DeviceID:    protocol.DeviceID,
				//		DeviceModel: protocol.DeviceModel,
				//		Address:     protocol.Address,
				//	},
				//}
				AddDevice(deviceinfo)
			}
			//handleInitialize(&protocol)
			protocol.DeviceID = deviceinfo.deviceid
			protocol.Type = -1
			conn.Write(serialize(&protocol))
		} else if protocol.FuncCode == FuncCodeInitialize {
			//if deviceinfo == nil {
			//	// 创建设备对象
			//	deviceinfo = &DeviceInfo{
			//		deviceid:          DeviceMng.addDeviceID(),
			//		conn:              conn,
			//		status:            1,
			//		lastKeepaliveTime: time.Now().Unix(),
			//		subDeviceMap:      make(map[int32]*SubDeviceInfo),
			//	}
			//	//deviceinfo.subDeviceMap[protocol.Address] = &SubDeviceInfo{
			//	//	device: &models.Device{
			//	//		DeviceID:    protocol.DeviceID,
			//	//		DeviceModel: protocol.DeviceModel,
			//	//		Address:     protocol.Address,
			//	//	},
			//	//}
			//	AddDevice(deviceinfo)
			//}
			handleInitialize(&protocol)
			//protocol.DeviceID = deviceinfo.deviceid
			//protocol.Type = -1
			//conn.Write(serialize(&protocol))

		} else if protocol.FuncCode == FuncCodeUpparam {
			// 处理上传参数消息
			if deviceinfo != nil {
				// 创建设备对象
				//deviceinfo = &DeviceInfo{
				//	deviceid:          protocol.DeviceID,
				//	conn:              conn,
				//	status:            1,
				//	lastKeepaliveTime: time.Now().Unix(),
				//	subDeviceMap:      make(map[int32]*SubDeviceInfo),
				//}
				//deviceinfo.subDeviceMap[protocol.DeviceID] = &SubDeviceInfo{
				//	device: &models.Device{
				//		DeviceID:    protocol.DeviceID,
				//		DeviceModel: protocol.DeviceModel,
				//		Address:     protocol.Address,
				//	},
				//}
				//AddDevice(deviceinfo)
				handleUpparam(&protocol, conn, deviceinfo)
			}
		}

		//返回给客户端的信息
		//strTemp := "SocketServer has got msg \"" + string(buffer[:n]) + "\" at " + time.Now().String()
		//
		//fmt.Println(strTemp)
		//res := &models.RS485SingleFrameProtocol{}
		//res.Type = 1
		//res.Data = &models.OutParam{}
		//conn.Write(serialize(res))
	}
}

func handleKeepalive(protocol *models.RS485SingleFrameProtocol) {
	device := FindDevice(protocol.DeviceID)
	if device != nil {
		device.lastKeepaliveTime = time.Now().Unix()
	}
}

func handleInitialize(protocol *models.RS485SingleFrameProtocol) {
	handleKeepalive(protocol)
	dev := FindSubDevice(protocol.DeviceID, protocol.Address)
	if dev == nil {
		dev = &SubDeviceInfo{
			device: &models.Device{
				DeviceID:    protocol.DeviceID,
				DeviceModel: protocol.DeviceModel,
				Address:     protocol.Address,
			},
		}
		AddSubDevice(dev)
	}
	dev.onlineStatus = protocol.DeviceModel
}

func handleUpparam(protocol *models.RS485SingleFrameProtocol, conn net.Conn, deviceinfo *DeviceInfo) {
	handleKeepalive(protocol)
	models.SaveDeviceInfo(protocol) // 保存设备信息
	if protocol.Type == 0 {
		dev := FindSubDevice(protocol.DeviceID, protocol.Address)
		if dev == nil {
			dev = &SubDeviceInfo{
				device: &models.Device{
					DeviceID:    protocol.DeviceID,
					DeviceModel: protocol.DeviceModel,
					Address:     protocol.Address,
				},
			}
			AddSubDevice(dev)
		}
		dev.onlineStatus = protocol.DeviceModel
	}

}
