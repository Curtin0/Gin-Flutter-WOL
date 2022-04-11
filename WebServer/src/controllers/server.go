package controllers

import (
	"fmt"
	gnet "net"
	"sync"
	"time"
	"webserver/src/config"
	"webserver/src/models"
	"webserver/src/net"
)

type DeviceInfo struct {
	mutex             sync.Mutex
	deviceid          int32
	status            int32
	lastKeepaliveTime int64
	conn              gnet.Conn
	subDeviceMap      map[int32]*SubDeviceInfo
}

type SubDeviceInfo struct {
	device       *models.Device
	onlineStatus int32
}

type DeviceManager struct {
	mutex    sync.Mutex
	devMap   map[int32]*DeviceInfo
	maxDevID int32
	optchan  chan OperateInfo
}

var DeviceMng DeviceManager

func init() {
	err := net.GNet.Listen(config.Conf.SocketPort, accept)
	if err != nil {
		fmt.Printf("listen error:%v\n", err)
	}
	DeviceMng.devMap = make(map[int32]*DeviceInfo)
	DeviceMng.optchan = make(chan OperateInfo)
	DeviceMng.maxDevID = 1

	go func() {
		timer := time.NewTicker(5 * time.Second)
		for true {
			select {
			case <-timer.C:
				checkDevice()
			case op := <-DeviceMng.optchan:
				device := FindDevice(op.SocketClient)
				if device != nil && device.status == 1 {
					senddata(op, device.conn)
				} else {
					fmt.Printf("not found device:%v", op)
				}
			}
		}
	}()
}

// 检查设备状态
func checkDevice() {
	DeviceMng.mutex.Lock()
	defer DeviceMng.mutex.Unlock()
	now := time.Now().Unix()
	for _, dev := range DeviceMng.devMap {
		if now-dev.lastKeepaliveTime > 120 {
			dev.status = 0
		}
	}
}

func AddDevice(info *DeviceInfo) {
	temp := FindDevice(info.deviceid)
	if temp != nil {
		return
	}
	DeviceMng.mutex.Lock()
	DeviceMng.devMap[info.deviceid] = info
	DeviceMng.mutex.Unlock()
}

func FindDevice(id int32) *DeviceInfo {
	DeviceMng.mutex.Lock()
	defer DeviceMng.mutex.Unlock()
	return DeviceMng.devMap[id]
}

func DelDevice(id int32) {
	DeviceMng.mutex.Lock()
	defer DeviceMng.mutex.Unlock()
	delete(DeviceMng.devMap, id)
}

func GetAllDevice() []*DeviceInfo {
	DeviceMng.mutex.Lock()
	defer DeviceMng.mutex.Unlock()
	var reslist []*DeviceInfo
	for _, v := range DeviceMng.devMap {
		reslist = append(reslist, v)
	}
	return reslist
}

func AddSubDevice(dev *SubDeviceInfo) {
	temp := FindDevice(dev.device.DeviceID)
	if temp == nil {
		return
	}
	temp.mutex.Lock()
	temp.subDeviceMap[dev.device.Address] = dev
	temp.mutex.Unlock()
}

func FindSubDevice(id int32, address int32) *SubDeviceInfo {
	temp := FindDevice(id)
	if temp == nil {
		return nil
	}
	temp.mutex.Lock()
	defer temp.mutex.Unlock()
	return temp.subDeviceMap[address]
}

func GetAllSubDevices(id int32) []*SubDeviceInfo {
	var res []*SubDeviceInfo
	temp := FindDevice(id)
	if temp == nil {
		return nil
	}
	temp.mutex.Lock()
	defer temp.mutex.Unlock()
	for _, v := range temp.subDeviceMap {
		res = append(res, v)
	}
	return res
}

func DelSubDevice(id int32, address int32) {
	temp := FindDevice(id)
	if temp == nil {
		return
	}
	temp.mutex.Lock()
	defer temp.mutex.Unlock()
	delete(temp.subDeviceMap, address)
}

func (m *DeviceManager) addDeviceID() int32 {
	for true {
		dev := FindDevice(m.maxDevID)
		if dev == nil {
			id := m.maxDevID
			m.maxDevID++
			return id
		}
		m.maxDevID++
	}
	return -1
}
