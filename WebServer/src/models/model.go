package models

import "time"

// 设备表
type Device struct {
	DeviceID    int32 `xorm:"'device_id' not null pk int"`
	DeviceModel int32 `xorm:"'device_model' int"`
	Address     int32 `xorm:"'address' not null pk int"`
}

// 设备记录表
type DeviceRecord struct {
	ID              int64     `xorm:"'id' not null pk autoincr"`
	DeviceID        int32     `xorm:"'device_id' int"`
	DeviceModel     int32     `xorm:"'device_model' int"`
	Address         int32     `xorm:"'address' int"`
	Status          int32     `xorm:"'status' int"`           // 当前状态
	Fault           int32     `xorm:"'fault' int"`            // 当前故障
	Source          int32     `xorm:"'source' int"`           // 输入源
	Mode            int32     `xorm:"'mode' int"`             // 运行模式
	RotSpeed        int32     `xorm:"'rot_speed' int"`        // 风机转速，单位rpm
	NTCTemp         int32     `xorm:"'ntc_temp' int"`         // NTC温度，单位°C
	BusVoltage      int32     `xorm:"'bus_voltage' int"`      // 母线电压，单位V
	UCurrent        int32     `xorm:"'u_current' int"`        // U相电流，单位mA
	VCurrent        int32     `xorm:"'v_current' int"`        // V相电流，单位mA
	WCurrent        int32     `xorm:"'w_current' int"`        // W相电流，单位mA
	XAcceleration   int32     `xorm:"'x_acceleration' int"`   // X轴振动加速度, 单位mg
	YAcceleration   int32     `xorm:"'y_acceleration' int"`   // Y轴振动加速度, 单位mg
	ZAcceleration   int32     `xorm:"'z_acceleration' int"`   // Z轴振动加速度, 单位mg
	SumAcceleration int32     `xorm:"'sum_acceleration' int"` // 振动加速度矢量和, 单位mg
	RunTime         int32     `xorm:"'run_time' int"`         // 运行时间，单位s
	Version         string    `xorm:"'version' varchar(128)"` // 软件版本
	Time            time.Time `xorm:"'time' datetime"`        // UTC 时间
}

// 操作记录表
type OperateRecord struct {
	ID          int64     `xorm:"'id' not null pk autoincr"`
	DeviceID    int32     `xorm:"'device_id' int"`
	DeviceModel int32     `xorm:"'device_model' int"`
	Address     int32     `xorm:"'address' int"`
	Source      int32     `xorm:"source"`          // 输入源选择
	Mode        int32     `xorm:"mode"`            // 运行模式
	Level       int32     `xorm:"level"`           // 风量等级
	RotSpeed    int32     `xorm:"rot_speed"`       // 设置转速，负数代表反转，单位rpm
	Time        time.Time `xorm:"'time' datetime"` // UTC 时间
}

func AddDevice(device *Device) error {
	_, err := DB.engine.Insert(device)
	return err
}

func GetDevices() ([]*Device, error) {
	var arr []*Device
	err := DB.engine.Find(arr)
	if err != nil {
		return nil, err
	}
	return arr, err
}

func AddDeviceRecord(record *DeviceRecord) error {
	_, err := DB.engine.Insert(record)
	return err
}

func AddOperateRecord(record *OperateRecord) error {
	_, err := DB.engine.Insert(record)
	return err
}

func GetDeviceRecord(deviceid int32, address int32) *DeviceRecord {
	device := &DeviceRecord{
		DeviceID: deviceid,
		Address:  address,
	}
	ret, err := DB.engine.Desc("id").Get(device)
	if err != nil || ret == false {
		return nil
	}
	return device
}
