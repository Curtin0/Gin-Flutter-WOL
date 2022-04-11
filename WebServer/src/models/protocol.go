package models

import "time"

type RS485SingleFrameProtocol struct {
	DeviceID      int32       `json:"device_id"`      // 上位机id
	DeviceModel   int32       `json:"device_model"`   // 上位机模式
	Address       int32       `json:"address"`        // 地址
	FuncCode      int32       `json:"func_code"`      // 功能码
	MainVersion   int32       `json:"main_version"`   // 主版本
	BranchVersion int32       `json:"branch_version"` // 子版本
	Type          int32       `json:"_"`              // 参数类型, 0 : 上传参数，1：下发参数
	Data          interface{} `json:"data"`           // 参数
}

// 下发参数
type OutParam struct {
	Source   int32 `json:"source"`    // 输入源选择
	Mode     int32 `json:"mode"`      // 运行模式
	Level    int32 `json:"level"`     // 风量等级
	RotSpeed int32 `json:"rot_speed"` // 设置转速，负数代表反转，单位rpm
}

// 上传参数
type UpParam struct {
	Status          int32  `json:"status"`           // 当前状态
	Fault           int32  `json:"fault"`            // 当前故障
	Source          int32  `json:"source"`           // 输入源
	Mode            int32  `json:"mode"`             // 运行模式
	RotSpeed        int32  `json:"rot_speed"`        // 风机转速，单位rpm
	NTCTemp         int32  `json:"ntc_temp"`         // NTC温度，单位°C
	BusVoltage      int32  `json:"bus_voltage"`      // 母线电压，单位V
	UCurrent        int32  `json:"u_current"`        // U相电流，单位mA
	VCurrent        int32  `json:"v_current"`        // V相电流，单位mA
	WCurrent        int32  `json:"w_current"`        // W相电流，单位mA
	XAcceleration   int32  `json:"x_acceleration"`   //X轴振动加速度, 单位mg
	YAcceleration   int32  `json:"y_acceleration"`   //Y轴振动加速度, 单位mg
	ZAcceleration   int32  `json:"z_acceleration"`   //Z轴振动加速度, 单位mg
	SumAcceleration int32  `json:"sum_acceleration"` //振动加速度矢量和, 单位mg
	RunTime         int32  `json:"run_time"`         // 运行时间，单位s
	Version         string `json:"version"`          // 软件版本
}

func SaveDeviceInfo(protocol *RS485SingleFrameProtocol) error {
	AddDevice(&Device{
		DeviceID:    protocol.DeviceID,
		DeviceModel: protocol.DeviceModel,
		Address:     protocol.Address,
	})
	if protocol.Data != nil {
		if protocol.Type == 0 {
			param := (protocol.Data).(*UpParam)
			if param != nil {
				AddDeviceRecord(&DeviceRecord{
					DeviceID:        protocol.DeviceID,
					DeviceModel:     protocol.DeviceModel,
					Address:         protocol.Address,
					Status:          param.Status,
					Fault:           param.Fault,
					Source:          param.Source,
					Mode:            param.Mode,
					RotSpeed:        param.RotSpeed,
					NTCTemp:         param.NTCTemp,
					BusVoltage:      param.BusVoltage,
					UCurrent:        param.UCurrent,
					VCurrent:        param.VCurrent,
					WCurrent:        param.WCurrent,
					XAcceleration:   param.XAcceleration,
					YAcceleration:   param.YAcceleration,
					ZAcceleration:   param.ZAcceleration,
					SumAcceleration: param.SumAcceleration,
					RunTime:         param.RunTime,
					Version:         param.Version,
					Time:            time.Now().Local(),
				})
			}
		}
	}
	return nil
}
