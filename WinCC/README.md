# PMSM 风机监测系统 - WinCC

上位机网关模块，负责 RS485 串口与 TCP 服务器之间的数据透传。

## 概述

WinCC 网关是一个**被动透传**组件，无业务逻辑：
- 接收来自风机的 RS485 串口数据，转发至后端服务器
- 接收后端服务器的 TCP 指令，下发至风机
- 支持心跳检测和自动重连

## 技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| C# | - | 后端语言 |
| .NET Framework | 4.8 | 运行时 |
| Newtonsoft.Json | - | JSON 序列化 |

## 项目结构

```
WinCC/
├── Program.cs                 # 程序入口
├── config.json                # 配置文件
├── WinCC.csproj               # 项目文件
├── Core/                      # 核心模块
│   ├── Gateway.cs             # 网关核心逻辑
│   ├── GatewayConfig.cs       # 配置模型
│   ├── SerialPortService.cs   # 串口服务
│   └── TcpClientService.cs    # TCP 客户端服务
├── Protocol/                  # 通信协议
│   ├── FrameParser.cs         # 帧解析器
│   └── Crc16.cs               # CRC16 校验
└── Utils/                     # 工具类
    └── Logger.cs               # 日志系统
```

## 配置说明

配置文件 `config.json`：

```json
{
  "serial": {
    "port": "COM3",           // 串口名称
    "baudRate": 19200,        // 波特率
    "dataBits": 8,            // 数据位
    "stopBits": 1,            // 停止位
    "parity": 0,              // 校验位 (0=None, 1=Odd, 2=Even)
    "readTimeout": 3000,      // 读取超时 (ms)
    "writeTimeout": 3000      // 写入超时 (ms)
  },
  "server": {
    "ip": "112.74.182.249",   // 服务器 IP
    "port": 20019,            // 服务器端口
    "reconnectInterval": 5000,// 重连间隔 (ms)
    "connectTimeout": 10000   // 连接超时 (ms)
  },
  "gateway": {
    "id": 1,                  // 网关 ID
    "heartbeatInterval": 15000 // 心跳间隔 (ms)
  },
  "log": {
    "level": "info",          // 日志级别: debug/info/warn/error/fatal
    "path": "./logs/gateway.log",  // 日志文件路径
    "maxFiles": 7,             // 最多保留日志文件数
    "maxSize": 10485760       // 单个日志文件最大大小 (字节)
  }
}
```

## 通信协议

### 帧格式

```
[帧头1] [帧头2] [地址] [功能码] [数据...] [CRC16低] [CRC16高]
0x20    0x01
```

### 功能码

| 功能码 | 名称 | 帧长度 |
|--------|------|--------|
| 0x0F | 初始化帧 | 12 |
| 0x0E | 心跳帧 | 12 |
| 0x0D | ID 分配帧 | 12 |
| 0x2B | 设备识别帧 | 42 |
| 0x41 | 正常运行帧 | 50 |

### 从站地址

有效地址范围：`0x21 - 0x28` (8 个从站)

### CRC16 校验

使用标准 Modbus CRC16 算法。

## 数据流

```
风机 (RS485) → WinCC (串口) → 透传 → TCP → WebServer
WebServer → TCP → WinCC → 透传 → 串口 → 风机
```

## 启动方式

### 方式一：Visual Studio

```bash
# 使用 Visual Studio 打开 WinCC.slnx
# 编译运行
```

### 方式二：命令行

```bash
# 默认配置
WinCC.exe

# 指定配置文件
WinCC.exe -c config.json
```

### 方式三：编译

```bash
# 使用 MSBuild 或 dotnet CLI 编译
csc /target:exe /out:WinCC.exe Program.cs Core/*.cs Protocol/*.cs Utils/*.cs
```

## 命令行参数

| 参数 | 说明 | 示例 |
|------|------|------|
| -c | 指定配置文件路径 | `WinCC.exe -c myconfig.json` |

## 日志说明

日志文件默认保存在 `./logs/gateway.log`，支持日志轮转：

- 单个文件最大 10MB
- 最多保留 7 个文件
- 日志级别：debug < info < warn < error < fatal

## 运行日志示例

```
===========================================
WinCC Gateway v1.0.0 - PMSM Fan Data Gateway
===========================================
Configuration:
  Serial: COM3 @ 19200bps
  Server: 112.74.182.249:20019
  Gateway ID: 1
Loaded config from: config.json
Starting Gateway...
TCP connected
Gateway started successfully
Press Ctrl+C to stop the gateway...
```

## 注意事项

1. 串口参数需与风机设备匹配（默认 19200-8-1-N）
2. 确保服务器 IP 和端口可访问
3. 无硬件时可使用演示模式（跳过串口）
4. 日志目录需要写权限
5. Windows 防火墙可能阻止 TCP 连接

## 故障排查

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| 串口打开失败 | 串口不存在或被占用 | 检查 COM 口是否正确 |
| TCP 连接失败 | 网络不通或服务器未启动 | 检查网络和服务器 |
| 数据解析错误 | 帧格式不匹配 | 检查 CRC 校验 |
| 频繁断连 | 网络不稳定 | 调整重连间隔 |
