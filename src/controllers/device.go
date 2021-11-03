package controllers

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
	"webserver/src/models"
)

type QueryFilterTemp struct {
	Check        string `json:"check"`
	SocketClient string `json:"socket_client"`
	Address      string `json:"address"`
}

type QueryDeviceTemp struct {
	OnlineStatus    string `json:"online_status"`
	SocketClient    string `json:"socket_client"`
	Address         string `json:"address"`
	Status          string `json:"status"`
	Fault           string `json:"fault"`
	Source          string `json:"source"`
	Mode            string `json:"mode"`
	RotSpeed        string `json:"rot_speed"`
	NTCTemp         string `json:"ntc_temp"`
	BusVoltage      string `json:"bus_voltage"`
	UCurrent        string `json:"u_current"`
	VCurrent        string `json:"v_current"`
	WCurrent        string `json:"w_current"`
	XAcceleration   string `json:"x_acceleration"`
	YAcceleration   string `json:"y_acceleration"`
	ZAcceleration   string `json:"z_acceleration"`
	SumAcceleration string `json:"sum_acceleration"`
	RunTime         string `json:"run_time"`
	Version         string `json:"version"`
	NowTime         string `json:"now_time"`
}

type QueryReponse struct {
	Code int32           `json:"code"`
	Msg  string          `json:"msg"`
	Data QueryDeviceTemp `json:"data"`
}

type OnlineItemReq struct {
	SocketClient int32 `json:"socket_client"`
	Address      int32 `json:"address"`
}

type DeviceOnlineItem struct {
	SocketClient string `json:"socket_client"`
	OnlineStatus string `json:"online_status"`
	Name         string `json:"name"`
	Description  string `json:"description"`
}

type SubDeviceOnlineItem struct {
	Address             string `json:"address"`
	AddressOnlineStatus string `json:"address_online_status"`
}

type DeviceOnlineRequest struct {
	SocketClient string `json:"socket_client"`
}

type OnlineResponse struct {
	Code     int32       `json:"code"`
	Msg      string      `json:"msg"`
	DataList interface{} `json:"data_list"`
}

func intToString(value int32) string {
	return fmt.Sprintf("%v", value)
}

func Query(ctx *gin.Context) {
	var filtertemp QueryFilterTemp

	if err := ctx.ShouldBindJSON(&filtertemp); err != nil {
		ctx.JSON(http.StatusOK, QueryReponse{
			Code: -1,
			Msg:  err.Error(),
		})
		return
	}

	deviceid := string2Int32(filtertemp.SocketClient)
	address := string2Int32(filtertemp.Address)
	device := models.GetDeviceRecord(deviceid, address)
	if device == nil {
		ctx.JSON(http.StatusOK, QueryReponse{
			Code: -2,
			Msg:  fmt.Sprintf("not find device id:%v, address:%v", filtertemp.SocketClient, filtertemp.Address),
		})
		return
	}

	subdevice := FindSubDevice(deviceid, address)

	var onlineStatus int32 = 0
	if subdevice == nil {
		onlineStatus = 0
	} else {
		onlineStatus = subdevice.onlineStatus
	}

	temp := QueryDeviceTemp{
		OnlineStatus:    intToString(onlineStatus),
		SocketClient:    intToString(device.DeviceID),
		Address:         intToString(device.Address),
		Status:          DeviceStatus[device.Status],
		Fault:           GetDeviceFault(device.Fault),
		Source:          DeviceSource[device.Source],
		Mode:            DeviceMode[device.Mode],
		RotSpeed:        intToString(device.RotSpeed),
		NTCTemp:         intToString(device.NTCTemp),
		BusVoltage:      intToString(device.BusVoltage),
		UCurrent:        intToString(device.UCurrent),
		VCurrent:        intToString(device.VCurrent),
		WCurrent:        intToString(device.WCurrent),
		XAcceleration:   intToString(device.XAcceleration),
		YAcceleration:   intToString(device.YAcceleration),
		ZAcceleration:   intToString(device.ZAcceleration),
		SumAcceleration: intToString(device.SumAcceleration),
		RunTime:         intToString(device.RunTime),
		Version:         device.Version,
		NowTime:         device.Time.Local().String(),
	}
	ctx.JSON(http.StatusOK, QueryReponse{
		Code: 0,
		Msg:  "OK",
		Data: temp,
	})
}

func DeviceOnline(ctx *gin.Context) {
	var req DeviceOnlineRequest

	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusOK, OnlineResponse{
			Code: -1,
			Msg:  err.Error(),
		})
		return
	}

	var devlist []*DeviceInfo
	if req.SocketClient == "all" {
		devlist = GetAllDevice()
	} else {
		dev := FindDevice(string2Int32(req.SocketClient))
		if dev != nil {
			devlist = append(devlist, dev)
		}
	}

	res := OnlineResponse{
		Code: 0,
		Msg:  "OK",
	}

	var datalist []DeviceOnlineItem

	for _, obj := range devlist {
		item := DeviceOnlineItem{
			SocketClient: intToString(obj.deviceid),
			OnlineStatus: intToString(obj.status),
			Name:         fmt.Sprintf("PMSM上位机%v", obj.deviceid),
			Description:  fmt.Sprintf("PMSM上位机%v-设备列表", obj.deviceid),
		}
		datalist = append(datalist, item)
	}
	res.DataList = datalist
	ctx.JSON(http.StatusOK, res)
}

func SubDeviceOnline(ctx *gin.Context) {
	var req DeviceOnlineRequest

	if err := ctx.ShouldBindJSON(&req); err != nil {
		ctx.JSON(http.StatusOK, OnlineResponse{
			Code: -1,
			Msg:  err.Error(),
		})
		return
	}

	res := OnlineResponse{
		Code: 0,
		Msg:  "OK",
	}

	subdevlist := GetAllSubDevices(string2Int32(req.SocketClient))

	var datalist []SubDeviceOnlineItem

	for _, obj := range subdevlist {
		item := SubDeviceOnlineItem{
			Address:             intToString(obj.device.Address),
			AddressOnlineStatus: intToString(obj.onlineStatus),
		}
		datalist = append(datalist, item)
	}

	res.DataList = datalist

	ctx.JSON(http.StatusOK, res)
}
