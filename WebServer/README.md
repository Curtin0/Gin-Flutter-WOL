# PMSM 风机监测系统 - WebServer

后端服务模块，负责提供 HTTP API 接口和 TCP Socket 通信，接收网关转发的风机数据并存储。

## 技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Go | 1.26+ | 后端语言 |
| Gin | v1.10.0 | HTTP 框架 |
| Gorilla WebSocket | v1.5.3 | WebSocket 实时推送 |
| Xorm | v1.3.9 | ORM 框架 |
| SQLite | modernc.org/sqlite | 嵌入式数据库 |

## 项目结构

```
WebServer/
├── main.go                    # 程序入口
├── go.mod                     # 依赖管理
├── conf/
│   └── config.conf            # 配置文件
├── data/
│   └── webserver.db           # SQLite 数据库
├── doc/
│   └── swagger/               # API 文档
└── src/
    ├── config/                # 配置加载
    │   └── config.go
    ├── controllers/           # 请求处理
    │   ├── device.go          # 设备查询
    │   ├── file.go            # 文件上传下载
    │   ├── operate.go         # 设备控制
    │   ├── protocol.go        # 协议解析
    │   ├── server.go          # 服务器状态
    │   ├── socketconn.go      # TCP 连接管理
    │   ├── utils.go           # 工具函数
    │   └── websocket.go       # WebSocket 处理
    ├── httpserver/            # HTTP 服务封装
    │   └── httpserver.go
    ├── models/                # 数据模型
    │   ├── model.go           # 设备数据结构
    │   ├── protocol.go        # 通信协议模型
    │   └── server.go          # 服务器模型
    ├── net/                   # TCP Socket
    │   └── socket.go
    ├── routers/               # 路由注册
    │   └── router.go
    └── sysinit/               # 系统初始化
        └── init.go
```

## 配置说明

配置文件位于 `conf/config.conf`，首次运行自动创建：

```json
{
    "WebPort": 8080,        // HTTP 服务端口
    "SocketPort": 8000,     // TCP Socket 端口
    "DBPath": "data/webserver.db",  // 数据库路径
    "FilePath": "upload"    // 文件上传目录
}
```

## 数据模型

### Device 设备表

| 字段 | 类型 | 说明 |
|------|------|------|
| device_id | int32 | 网关 ID |
| device_model | int32 | 设备型号 |
| address | int32 | 设备地址 |

### DeviceRecord 设备记录表

| 字段 | 类型 | 说明 |
|------|------|------|
| device_id | int32 | 网关 ID |
| device_model | int32 | 设备型号 |
| address | int32 | 设备地址 |
| status | int32 | 运行状态 |
| fault | int32 | 故障代码 |
| source | int32 | 输入源 |
| mode | int32 | 运行模式 |
| rot_speed | int32 | 转速 (rpm) |
| ntc_temp | int32 | NTC 温度 (°C) |
| bus_voltage | int32 | 母线电压 (V) |
| u_current | int32 | U 相电流 (mA) |
| v_current | int32 | V 相电流 (mA) |
| w_current | int32 | W 相电流 (mA) |
| x_acceleration | int32 | X 轴振动加速度 (mg) |
| y_acceleration | int32 | Y 轴振动加速度 (mg) |
| z_acceleration | int32 | Z 轴振动加速度 (mg) |
| sum_acceleration | int32 | 振动加速度矢量和 (mg) |
| run_time | int32 | 运行时间 (s) |
| version | string | 软件版本 |
| time | datetime | 数据时间 |

### OperateRecord 操作记录表

| 字段 | 类型 | 说明 |
|------|------|------|
| device_id | int32 | 网关 ID |
| device_model | int32 | 设备型号 |
| address | int32 | 设备地址 |
| source | int32 | 输入源选择 |
| mode | int32 | 运行模式 |
| level | int32 | 风量等级 |
| rot_speed | int32 | 设置转速 (rpm) |
| time | datetime | 操作时间 |

## API 接口

### WebSocket

| 路径 | 方法 | 说明 |
|------|------|------|
| /api/v1/websocket | GET | 实时数据推送 |

### HTTP API

| 路径 | 方法 | 说明 |
|------|------|------|
| /record | POST | 设备数据上报 |
| /query | POST | 查询设备数据 |
| /online | POST | 查询网关在线状态 |
| /online_inside | POST | 查询子设备在线状态 |
| /download/:filename | GET | 文件下载 |
| /version | POST | 版本查询 |

### 接口详情

#### POST /record - 设备数据上报

请求网关上报设备运行数据。

#### POST /query - 查询设备数据

查询指定设备最新数据。

**请求参数：**
```json
{
    "socket_client": "1",   // 网关 ID
    "address": "1"         // 设备地址
}
```

**响应：**
```json
{
    "code": 0,
    "msg": "OK",
    "data": {
        "online_status": "1",
        "socket_client": "1",
        "address": "1",
        "status": "运行",
        "fault": "正常",
        "source": "本地",
        "mode": "自动",
        "rot_speed": "1000",
        "ntc_temp": "25",
        "bus_voltage": "220",
        "u_current": "500",
        "v_current": "500",
        "w_current": "500",
        "x_acceleration": "10",
        "y_acceleration": "10",
        "z_acceleration": "10",
        "sum_acceleration": "17",
        "run_time": "3600",
        "version": "v1.0.0",
        "now_time": "2024-01-01 12:00:00"
    }
}
```

#### POST /online - 网关在线状态

**请求参数：**
```json
{
    "socket_client": "all"  // all 或具体网关 ID
}
```

#### POST /online_inside - 子设备在线状态

**请求参数：**
```json
{
    "socket_client": "1"    // 网关 ID
}
```

## 启动方式

### 方式一：直接运行

```bash
cd WebServer
go run main.go
```

服务启动后：
- HTTP 服务：http://localhost:8080
- TCP Socket：localhost:8000
- API 文档：http://localhost:8080/swagger/index.html

### 方式二：运行已编译程序

```bash
cd WebServer
./webserver.exe
```

### 方式三：编译

```bash
cd WebServer
go build -o webserver.exe main.go
```

## 通信协议

### TCP 协议

网关通过 TCP 连接到服务器 (默认端口 8000)，发送风机数据帧。

帧格式：
```
[起始码] [长度] [数据类型] [数据] [CRC16] [结束码]
```

### WebSocket 推送

当设备数据发生变化时，服务器通过 WebSocket 主动推送到客户端。

## 依赖管理

```bash
# 安装依赖
go mod tidy

# 查看依赖
go list -m all
```

## 注意事项

1. 首次运行自动创建数据库文件和配置
2. 确保 8080 和 8000 端口未被占用
3. 上传目录需要写权限
4. 数据库文件建议定期备份
