package models

import "time"

// 设备表
type Device struct {
	DeviceID    int32 `xorm:"'device_id' not null pk INT(10)"`
	DeviceModel int32 `xorm:"'device_model' INT(10)"`
	Address     int32 `xorm:"'address' not null pk INT(10)"`
}

// 设备记录表
type DeviceRecord struct {
	ID              int64     `xorm:"'id' not null pk autoincr BIGINT(20)"`
	DeviceID        int32     `xorm:"'device_id' INT(10)"`
	DeviceModel     int32     `xorm:"'device_model' INT(10)"`
	Address         int32     `xorm:"'address' INT(10)"`
	Status          int32     `xorm:"'status' INT(10)"`           // 当前状态
	Fault           int32     `xorm:"'fault' INT(10)"`            // 当前故障
	Source          int32     `xorm:"'source' INT(10)"`           // 输入源
	Mode            int32     `xorm:"'mode' INT(10)"`             // 运行模式
	RotSpeed        int32     `xorm:"'rot_speed' INT(10)"`        // 风机转速，单位rpm
	NTCTemp         int32     `xorm:"'ntc_temp' INT(10)"`         // NTC温度，单位°C
	BusVoltage      int32     `xorm:"'bus_voltage' INT(10)"`      // 母线电压，单位V
	UCurrent        int32     `xorm:"'u_current' INT(10)"`        // U相电流，单位mA
	VCurrent        int32     `xorm:"'v_current' INT(10)"`        // V相电流，单位mA
	WCurrent        int32     `xorm:"'w_current' INT(10)"`        // W相电流，单位mA
	XAcceleration   int32     `xorm:"'x_acceleration' INT(10)"`   // X轴振动加速度, 单位mg
	YAcceleration   int32     `xorm:"'y_acceleration' INT(10)"`   // Y轴振动加速度, 单位mg
	ZAcceleration   int32     `xorm:"'z_acceleration' INT(10)"`   // Z轴振动加速度, 单位mg
	SumAcceleration int32     `xorm:"'sum_acceleration' INT(10)"` // 振动加速度矢量和, 单位mg
	RunTime         int32     `xorm:"'run_time' INT(10)"`         // 运行时间，单位s
	Version         string    `xorm:"'version' VARCHAR(128)"`     // 软件版本
	Time            time.Time `xorm:"'time' DATETIME"`            // UTC 时间
}

// 操作记录表
type OperateRecord struct {
	ID          int64     `xorm:"'id' not null pk autoincr BIGINT(20)"`
	DeviceID    int32     `xorm:"'device_id' INT(10)"`
	DeviceModel int32     `xorm:"'device_model' INT(10)"`
	Address     int32     `xorm:"'address' INT(10)"`
	Source      int32     `xorm:"source"`          // 输入源选择
	Mode        int32     `xorm:"mode"`            // 运行模式
	Level       int32     `xorm:"level"`           // 风量等级
	RotSpeed    int32     `xorm:"rot_speed"`       // 设置转速，负数代表反转，单位rpm
	Time        time.Time `xorm:"'time' DATETIME"` // UTC 时间
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
