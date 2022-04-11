package controllers

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"net/http"
	"strconv"
)

type OperateInfo struct {
	Operate           int32 `json:"operate"`
	SocketClient      int32 `json:"socket_client"`
	SocketClientModel int32 `json:"socket_client_model"`
	Address           int32 `json:"address"`
	Source            int32 `json:"source"`
	Mode              int32 `json:"mode"`
	Level             int32 `json:"level"`
	RotSpeed          int32 `json:"rot_speed"`
}

type OperateInfoTemp struct {
	Operate           string `json:"operate"`
	SocketClient      string `json:"socket_client"`
	SocketClientModel string `json:"socket_client_model"`
	Address           string `json:"address"`
	Source            string `json:"source"`
	Mode              string `json:"mode"`
	Level             string `json:"level"`
	RotSpeed          string `json:"rot_speed"`
}

func string2Int32(str string) int32 {
	num, err := strconv.Atoi(str)
	if err != nil {
		return 0
	}
	return int32(num)
}

func OperateInfoTransform(temp *OperateInfoTemp) *OperateInfo {
	opt := &OperateInfo{
		Operate:           string2Int32(temp.Operate),
		SocketClient:      string2Int32(temp.SocketClient),
		SocketClientModel: string2Int32(temp.SocketClientModel),
		Address:           string2Int32(temp.Address),
		Source:            string2Int32(temp.Source),
		Mode:              string2Int32(temp.Mode),
		Level:             string2Int32(temp.Level),
		RotSpeed:          string2Int32(temp.RotSpeed),
	}
	return opt
}

type OptReponse struct {
	Code int32  `json:"code"`
	Msg  string `json:"msg"`
}

func Operate(ctx *gin.Context) {
	var opttemp OperateInfoTemp

	if err := ctx.ShouldBindJSON(&opttemp); err != nil {
		ctx.JSON(http.StatusOK, OptReponse{
			Code: -1,
			Msg:  err.Error(),
		})
		return
	}

	opt := OperateInfoTransform(&opttemp)
	// 查找设备
	deviceinfo := FindDevice(opt.SocketClient)
	if deviceinfo != nil {
		DeviceMng.optchan <- *opt
		ctx.JSON(http.StatusOK, OptReponse{
			Code: 0,
			Msg:  "OK",
		})
		return
	} else {
		fmt.Printf("not found device:%v", opt)
	}
	ctx.JSON(http.StatusOK, OptReponse{
		Code: -2,
		Msg:  "error",
	})
}
