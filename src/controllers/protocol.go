package controllers

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"webserver/src/models"
)

func deserialize(data []byte, protocol *models.RS485SingleFrameProtocol) int {
	if len(data) < 5 {
		return 0
	}
	bytesBuffer := bytes.NewBuffer(data)
	protocol.DeviceID = int32(bytesToUInt32(bytesBuffer))
	protocol.DeviceModel = int32(bytesToUInt8(bytesBuffer))
	protocol.Address = int32(bytesToUInt8(bytesBuffer))
	protocol.FuncCode = int32(bytesToUInt8(bytesBuffer))
	protocol.MainVersion = int32(bytesToUInt8(bytesBuffer))
	protocol.BranchVersion = int32(bytesToUInt8(bytesBuffer))
	var ln uint8 = bytesToUInt8(bytesBuffer)
	if int(ln) > bytesBuffer.Len() {
		return 0
	}
	if protocol.Type == 0 {
		param := &models.UpParam{}
		protocol.Data = param
		l := deserializeOutParm(bytesBuffer.Bytes(), param)
		bytesBuffer.Next(l)
		if bytesBuffer.Len() >= 2 {
			count := len(data) - bytesBuffer.Len()
			ccrc16 := LittleEndianBytesToUInt16(bytesBuffer)
			crc16 := CheckSum(data[:count])
			if crc16 != ccrc16 {
				fmt.Printf("crc check failed\n")
			} else {
				fmt.Printf("crc check success\n")
			}
		}

		return len(data) - bytesBuffer.Len()
	}
	return -1
}

func serialize(protocol *models.RS485SingleFrameProtocol) []byte {
	bytesBuffer := bytes.NewBuffer([]byte{})
	bytesBuffer.Write(uInt32ToBytes(uint32(protocol.DeviceID)))
	bytesBuffer.Write(uInt8ToBytes(uint8(protocol.DeviceModel)))
	bytesBuffer.Write(uInt8ToBytes(uint8(protocol.Address)))
	bytesBuffer.Write(uInt8ToBytes(uint8(protocol.FuncCode)))
	bytesBuffer.Write(uInt8ToBytes(uint8(protocol.MainVersion)))
	bytesBuffer.Write(uInt8ToBytes(uint8(protocol.BranchVersion)))
	if protocol.Type == 1 {
		param := (protocol.Data).(*models.OutParam)
		data := serializeUpParam(param)
		bytesBuffer.Write(uInt8ToBytes(uint8(len(data))))
		bytesBuffer.Write(data)
		crc16 := CheckSum(bytesBuffer.Bytes()[5:])
		bytesBuffer.Write(uInt16ToLittleEndianBytes(crc16))
		return bytesBuffer.Bytes()
	} else {
		bytesBuffer.Write(uInt8ToBytes(0))
		bytesBuffer.Write(uInt16ToLittleEndianBytes(0))
		return bytesBuffer.Bytes()
	}

	return nil
}

func serializeUpParam(param *models.OutParam) []byte {
	bytesBuffer := bytes.NewBuffer([]byte{})
	bytesBuffer.Write(uInt8ToBytes(uint8(param.Source)))
	bytesBuffer.Write(uInt8ToBytes(uint8(param.Mode)))
	bytesBuffer.Write(uInt16ToBytes(uint16(param.Level)))
	bytesBuffer.Write(uInt16ToBytes(uint16(param.RotSpeed)))
	return bytesBuffer.Bytes()
}

func deserializeOutParm(data []byte, param *models.UpParam) int {
	bytesBuffer := bytes.NewBuffer(data)
	param.Status = int32(bytesToUInt32(bytesBuffer))
	param.Fault = int32(bytesToUInt32(bytesBuffer))
	param.Source = int32(bytesToUInt8(bytesBuffer))
	param.Mode = int32(bytesToUInt8(bytesBuffer))
	param.RotSpeed = int32(bytesToInt16(bytesBuffer))
	param.NTCTemp = int32(bytesToInt16(bytesBuffer))
	param.BusVoltage = int32(bytesToUInt16(bytesBuffer))
	param.UCurrent = int32(bytesToUInt16(bytesBuffer))
	param.VCurrent = int32(bytesToUInt16(bytesBuffer))
	param.WCurrent = int32(bytesToUInt16(bytesBuffer))
	param.XAcceleration = int32(bytesToInt16(bytesBuffer))
	param.YAcceleration = int32(bytesToInt16(bytesBuffer))
	param.ZAcceleration = int32(bytesToInt16(bytesBuffer))
	param.SumAcceleration = int32(bytesToInt16(bytesBuffer))
	param.RunTime = int32(bytesToUInt32(bytesBuffer))
	param.Version = versionStr(bytesToUInt32(bytesBuffer))
	return len(data) - bytesBuffer.Len()
}

//字节转换成uint8
func bytesToUInt8(buf *bytes.Buffer) uint8 {
	var uval8 uint8 = 0
	binary.Read(buf, binary.BigEndian, &uval8)

	return uval8
}

func uInt8ToBytes(val uint8) []byte {
	bytesBuffer := bytes.NewBuffer([]byte{})
	binary.Write(bytesBuffer, binary.BigEndian, val)
	return bytesBuffer.Bytes()
}

func bytesToUInt32(buf *bytes.Buffer) uint32 {
	var uval32 uint32 = 0
	binary.Read(buf, binary.BigEndian, &uval32)

	return uval32
}

func uInt16ToBytes(val uint16) []byte {
	bytesBuffer := bytes.NewBuffer([]byte{})
	binary.Write(bytesBuffer, binary.BigEndian, val)
	return bytesBuffer.Bytes()
}

func uInt16ToLittleEndianBytes(val uint16) []byte {
	bytesBuffer := bytes.NewBuffer([]byte{})
	binary.Write(bytesBuffer, binary.LittleEndian, val)
	return bytesBuffer.Bytes()
}

func bytesToUInt16(buf *bytes.Buffer) uint16 {
	var uval16 uint16 = 0
	binary.Read(buf, binary.BigEndian, &uval16)

	return uval16
}

func bytesToInt16(buf *bytes.Buffer) int16 {
	var val16 int16 = 0
	binary.Read(buf, binary.BigEndian, &val16)

	return val16
}

func LittleEndianBytesToUInt16(buf *bytes.Buffer) uint16 {
	var uval16 uint16 = 0
	binary.Read(buf, binary.LittleEndian, &uval16)

	return uval16
}

func uInt32ToBytes(val uint32) []byte {
	bytesBuffer := bytes.NewBuffer([]byte{})
	binary.Write(bytesBuffer, binary.BigEndian, val)
	return bytesBuffer.Bytes()
}

func versionStr(ver uint32) string {
	c := ver & 0xFF
	b := (ver >> 8) & 0xFF
	a := (ver >> 16) & 0xFFFF
	return fmt.Sprintf("V%v.%v%v", a, b, c)
}
