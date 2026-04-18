# PMSM 风机监测系统 - 测试链路

本文档说明如何从 **WinCC 虚拟风机模式** 测试到 **AppGUI** 的完整数据流。

## 测试拓扑

```
[WinCC 虚拟风机] → TCP(:20019) → [WebServer] → SQLite → HTTP(:8080) → [AppGUI]
```

## 1. 环境准备

### 1.1 编译项目

```bash
# 编译 WebServer
cd WebServer
go build -o webserver.exe main.go

# 编译 WinCC
cd WinCC
dotnet build -c Release
```

### 1.2 目录结构

```
项目根目录/
├── WebServer/
│   ├── webserver.exe                # 编译后的后端服务
│   ├── conf/config.conf             # 配置文件
│   └── data/                        # SQLite 数据库
├── WinCC/
│   ├── bin/Release/net48/WinCC.exe  # 编译后的网关
│   └── config.json                  # 配置文件
├── AppGUI/                          # Flutter 桌面客户端 (可选)
└── docs/
    └── TEST.md                      # 本文档
```

## 2. 配置文件

### 2.1 WebServer 配置

文件: `WebServer/conf/config.conf`

```json
{
    "WebPort": 8080,
    "SocketPort": 20019,
    "DBPath": "data/webserver.db",
    "FilePath": "upload"
}
```

**说明:**
- `WebPort`: HTTP 服务端口 (8080)
- `SocketPort`: TCP 监听端口 (20019)

### 2.2 WinCC 配置

文件: `WinCC/config.json`

**完整配置 (网关模式 + 虚拟风机模式共存):**

```json
{
  "server": {
    "ip": "127.0.0.1",
    "port": 20019,
    "reconnectInterval": 5000,
    "connectTimeout": 10000
  },
  "gateway": {
    "id": 1,
    "heartbeatInterval": 5000,
    "serial": {
      "port": "COM3",
      "baudRate": 19200,
      "dataBits": 8,
      "stopBits": 1,
      "parity": 0,
      "readTimeout": 3000,
      "writeTimeout": 3000
    }
  },
  "virtualFan": {
    "enabled": true,
    "reportInterval": 5000
  },
  "log": {
    "level": "debug",
    "path": "./logs/gateway.log",
    "maxFiles": 7,
    "maxSize": 10485760
  }
}
```

**配置说明:**

| 字段 | 说明 | 网关模式 | 虚拟风机模式 |
|------|------|----------|--------------|
| `server.ip` | 服务器地址 | 127.0.0.1 | 127.0.0.1 |
| `server.port` | TCP 端口 | 20019 | 20019 |
| `gateway.id` | 网关 ID | 1 | 1 |
| `gateway.serial.port` | 串口名称 | COM3 | (不需要) |
| `gateway.serial.baudRate` | 波特率 | 19200 | (不需要) |
| `virtualFan.enabled` | 启用虚拟风机 | **false** | **true** |
| `virtualFan.reportInterval` | 数据上报间隔(ms) | - | 5000 |

## 3. 启动步骤

### 3.1 启动 WebServer

```bash
cd WebServer
./webserver.exe
```

**预期输出:**
```
httpserver port:8080
tcp listen port:20019
Waiting for clients ...
[GIN-debug] GET    /api/v1/websocket
[GIN-debug] POST   /record
...
```

### 3.2 启动 WinCC (虚拟风机模式)

只需将 `virtualFan.enabled` 改为 `true`，其他配置保持不变：

```json
"virtualFan": {
  "enabled": true,
  "reportInterval": 5000
}
```

```bash
cd WinCC
./bin/Release/net48/WinCC.exe
```

**预期输出:**
```
Loaded config from: config.json
===========================================
WinCC Gateway v1.0.0 - PMSM Fan Data Gateway
===========================================
Run Mode: virtual_fan
Configuration:
  Server: 127.0.0.1:20019
  Gateway ID: 1
Starting Virtual Fan mode...
  Report Interval: 5000ms
Connecting to 127.0.0.1:20019...
Connected to server
Sent Assign ID request
Received Assign ID response (12 bytes)
Press Ctrl+C to stop the gateway...

[DEBUG] Sent Initialize frame
[DEBUG] Sent Normal data frame (50 bytes)
```

WinCC 会每 5 秒发送一次模拟风机数据。

## 4. 验证方法

### 4.1 查询设备数据 (HTTP API)

```bash
curl -X POST http://localhost:8080/query \
  -H "Content-Type: application/json" \
  -d '{"socket_client":"1","address":"33"}'
```

**注意:** 地址 `33` = 十六进制 `0x21`

**响应:**
```json
{
    "code": 0,
    "msg": "OK",
    "data": {
        "online_status": "0",
        "socket_client": "1",
        "address": "33",
        "status": "运行",
        "fault": "无故障",
        "source": "AC380V",
        "mode": "风量等级",
        "rot_speed": "1000",
        "ntc_temp": "40",
        "bus_voltage": "110",
        "u_current": "3000",
        "v_current": "3000",
        "w_current": "3000",
        "x_acceleration": "56",
        "y_acceleration": "40",
        "z_acceleration": "24",
        "sum_acceleration": "88",
        "run_time": "20000",
        "version": "V1.23",
        "now_time": "2026-04-18 12:00:14 +0800 CST"
    }
}
```

### 4.2 查询网关在线状态

```bash
curl -X POST http://localhost:8080/online \
  -H "Content-Type: application/json" \
  -d '{"socket_client":"all"}'
```

### 4.3 查看日志

WebServer 会在控制台输出接收到的数据:
```
00 00 00 01 01 21 41 01 00 26 ...
```

WinCC 日志文件: `WinCC/logs/gateway.log`

## 5. 模拟数据说明

虚拟风机发送的数据帧 (50字节):

| 字段 | 值 | 说明 |
|------|-----|------|
| DeviceID | 1 | 网关 ID |
| DeviceModel | 1 | 在线 |
| Address | 0x21 | 设备地址 (33) |
| Status | 2 | 运行中 |
| Fault | 0 | 无故障 |
| Source | 3 | AC380V |
| Mode | 2 | 风量等级模式 |
| RotSpeed | 1000 | 转速 (rpm) |
| NTCTemp | 40 | 温度 (°C) |
| BusVoltage | 110 | 母线电压 (V) |
| U/V/W Current | 3000 | 相电流 (mA) |
| X/Y/Z Accel | 56/40/24 | 振动加速度 (mg) |
| Sum Accel | 88 | 合成加速度 (mg) |
| RunTime | 20000 | 运行时间 (秒) |
| Version | V1.2.3 | 软件版本 |

## 6. 切换到网关模式

如需测试真实串口设备，将 `enabled` 改为 `false`:

```json
"virtualFan": {
  "enabled": false,
  "reportInterval": 5000
}
```

## 7. 故障排查

| 问题 | 原因 | 解决 |
|------|------|------|
| 连接失败 | 端口被占用 | 检查 20019 端口 |
| 数据不更新 | WebServer 未启动 | 先启动 WebServer |
| 查询返回空 | 地址错误 | 地址应为十进制 33 (0x21) |
| CRC 校验失败 | 数据格式错误 | 检查帧格式是否正确 |
| 网关模式串口失败 | 串口不存在 | 检查 COM 口是否正确 |

## 8. 相关协议文档

- [USB-RS485-API.md](./USB-RS485-API.md) - 串口通信协议
- [TCP-API.md](./TCP-API.md) - TCP 通信协议
- [HTTP-API.yaml](./HTTP-API.yaml) - HTTP API 接口
