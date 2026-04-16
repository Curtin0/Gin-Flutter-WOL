# PMSM风机监测系统 - Flutter桌面应用

## 项目简介
这是一个用于监测PMSM（永磁同步电机）风机的Flutter桌面应用程序，支持Windows平台开发。该应用提供风机设备的实时监测、控制操作和演示功能。应用与多个上位机系统通信，管理4种不同类型的风机设备。

## 开发环境

### 依赖项
- Flutter SDK: >=3.0.0 <4.0.0 (实际使用3.41.0)
- Dart SDK: >=3.0.0 <4.0.0 (实际使用3.11.0)
- Windows 10/11 (桌面应用)
- 应用版本: 1.1.3

### 核心依赖包
- window_manager: ^0.4.3 - 桌面窗口控制
- window_size: ^0.1.0 - 窗口尺寸管理
- dio: ^4.0.6 - HTTP客户端
- web_socket_channel: ^2.4.0 - WebSocket实时通信
- event_bus: ^2.0.1 - 事件通信总线
- json_annotation: ^4.9.0 - JSON序列化
- fluttertoast: ^8.2.8 - 吐司提示
- pull_to_refresh: ^2.0.0 - 下拉刷新列表
- back_button_interceptor: ^8.0.4 - 返回按钮拦截
- date_format: ^2.0.9 - 日期格式化
- ota_update: ^4.0.0 - 空中更新
- package_info_plus: ^8.0.2 - 应用版本信息

## 编译步骤

### 1. 首次编译
```bash
cd E:\code project\07_Gin-Flutter-WOL\AppGUI
flutter pub get
flutter build windows --release
```

### 2. 构建产物位置
```
build/windows/x64/runner/Release/  # 主可执行文件
build/windows/x64/x64/Release/     # 安装位置
```

### 3. Windows构建配置
- 架构: x64
- 编译器: MSVC 4.2.3
- 构建系统: CMake
- 输出格式: Windows桌面应用

## 项目结构

```
AppGUI/
├── lib/                          # 主源代码目录
│   ├── main.dart                 # 应用入口点，窗口配置(450x800像素)
│   ├── generated_plugin_registrant.dart
│   ├── api/                      # HTTP通信层
│   │   ├── apis.dart             # API端点定义
│   │   ├── env_config.dart       # 开发/生产环境配置
│   │   ├── http_basis_util.dart  # 基础HTTP工具
│   │   └── http_util.dart        # Dio HTTP单例客户端
│   ├── base/                     # 数据模型
│   │   ├── base.dart             # BaseResponse, CommonResponse模型
│   │   └── base.g.dart           # 生成的JSON序列化代码
│   ├── components/               # 可复用UI组件
│   │   ├── alert_widget.dart     # 警告弹窗组件
│   │   ├── bottom_drawer.dart    # 底部抽屉组件
│   │   ├── common_utils.dart     # 通用工具函数
│   │   ├── dialog.dart           # 对话框组件
│   │   ├── jytoast.dart          # Toast提示组件
│   │   ├── list_view_group.dart  # 分组列表视图
│   │   ├── nodataview.dart       # 空数据状态视图
│   │   └── refresher.dart        # 刷新组件
│   ├── fan_controllers/          # 风机监控核心逻辑 ★
│   │   ├── fan_data_process.dart # 数据处理配置
│   │   ├── fan_demo_data.dart    # 演示数据统一管理
│   │   ├── fan_homepage.dart     # 风机列表页面(带WebSocket)
│   │   ├── fan_operation.dart    # 风机控制操作页面
│   │   ├── fan_vm.dart           # ViewModel业务逻辑层
│   │   └── version_update.dart   # 版本更新功能
│   ├── more/                     # 设置和更多页面
│   │   ├── application.dart      # 应用配置
│   │   ├── more_settings.dart    # 系统设置页面
│   │   └── websocket.dart        # WebSocket连接管理
│   └── providers/                # 状态管理
│       └── device_provider.dart  # 设备状态提供者
├── images/                       # 28个图片资源(中文命名图标)
├── android/                      # Android平台文件
├── ios/                          # iOS平台文件
├── windows/                      # Windows桌面平台文件
├── web/                          # Web平台文件
├── build/                        # 构建输出目录
├── pubspec.yaml                  # 依赖项和项目配置
└── analysis_options.yaml         # 代码分析配置
```

## 代码架构说明

### 1. MVC模式
- **Model**: base/ - 基础数据模型(BaseResponse, CommonResponse)
- **View**: fan_controllers/ - 页面视图(fan_homepage.dart, fan_operation.dart)
- **Controller**: fan_vm.dart - 业务逻辑和状态管理

### 2. 窗口配置
- **窗口尺寸**: 450x800像素
- **窗口标题**: "PMSM风机监测系统"
- **窗口位置**: 居中显示
- **主题**: Material 3，蓝色种子颜色(0xFF007AFF)，微软雅黑字体
- **导航**: 底部导航栏，2个标签页("风机监控", "系统设置")

### 3. 环境配置
- **开发环境**: http://localhost:8080, ws://localhost:8080
- **生产环境**: http://112.74.182.249, ws://112.74.182.249
- **当前环境**: 生产环境

### 4. 支持的设备类型
| 类型 | 型号 | Socket客户端ID | 记录端口 | 查询端口 |
|------|------|----------------|----------|----------|
| 1 | PMSM10C | 1 | /record | /query |
| 2 | PMSM04E | 2 | :20018/record | :20018/query |
| 3 | PMSM15 | 3 | :20014/record | :20014/query |
| 4 | PMSM10A | 4 | :20016/record | :20016/query |

### 5. 演示数据管理
- fan_demo_data.dart - 统一管理所有演示数据
- 避免在多处重复定义数据
- 支持4种风机类型各2个设备，共8个演示设备

### 6. 数据配置
- fan_data_process.dart - 使用配置对象管理不同设备类型的数据项
- 支持transform函数处理值转换
- 支持defaultValue处理缺失字段

## 主要功能

1. **风机列表展示** - 按4种类型分组显示风机设备
2. **实时监测** - 通过WebSocket获取实时数据(电压、电流、转速、温度等)
3. **风机控制** - 设置转速、风量等参数
4. **演示模式** - 无需连接服务器即可演示全部功能
5. **系统设置** - 环境配置、版本信息、更新检查
6. **多平台支持** - Windows桌面应用，支持响应式设计

## 图片资源

项目包含28个图片资源，主要用于监测界面：
- **监测图标**: time.png, 电压.png, 电流.png, 电流2.png, 电流3.png, 转速.png, 温度.png, 温度2.png, 振动加速度.png, x轴加速度.png, y轴加速度.png, z轴加速度.png
- **状态图标**: 上位机连接-yes.png, 上位机连接-no.png, 当前状态.png, 当前故障.png, 运行模式.png, 输入源.png, 编号.png, 版本.png, 累计运行时间.png
- **UI元素**: updateBg.png, null_state08.png, loading_idle.png, xl_loading.gif, tongye2pro.png, tick.png, 风机.png, motor.png

## 演示数据

项目内置演示数据，无需服务器即可运行：
- 8个风机设备（4种类型各2个）
- 实时监测数据模拟(电压、电流、转速、温度、振动等)
- 控制参数模拟
- 故障状态模拟

## 注意事项

1. **首次运行**需确保Flutter环境变量已正确配置
2. **国内用户**需配置镜像源以加速依赖下载
3. **演示模式下**所有数据均为模拟数据，不连接真实服务器
4. **窗口管理**使用window_manager包，需要桌面平台支持
5. **WebSocket连接**需要服务器支持，演示模式可绕过此限制

## 镜像配置

如遇网络问题，配置国内镜像：

**Windows PowerShell:**
```powershell
$env:PUB_HOSTED_URL="https://pub.flutter-io.cn"
$env:FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
```

**Windows CMD:**
```cmd
set PUB_HOSTED_URL=https://pub.flutter-io.cn
set FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

## 快速开始

1. **克隆项目**到本地
2. **确保Flutter环境**已正确安装(Flutter 3.0.0+)
3. **运行依赖安装**: `flutter pub get`
4. **启动应用**: `flutter run` (Windows桌面)
5. **构建发布版**: `flutter build windows --release`

## 开发说明

- **项目版本**: 1.1.3
- **Flutter版本**: 3.41.0稳定版
- **Dart版本**: 3.11.0
- **目标平台**: Windows桌面应用为主
- **设计模式**: 响应式设计，适配不同窗口尺寸
- **通信方式**: HTTP + WebSocket实时通信
- **数据管理**: 内置演示模式，便于测试和展示

## 技术特点

1. **实时监控**: WebSocket实现实时数据更新
2. **多设备支持**: 4种风机类型，8个演示设备
3. **离线演示**: 内置完整演示数据，无需服务器
4. **桌面优化**: 专门为Windows桌面平台优化
5. **状态管理**: 使用Provider进行状态管理
6. **事件通信**: EventBus实现组件间通信

## 项目关联

本项目是"Gin-Flutter-WOL"项目的前端部分，与以下组件协同工作：
- **后端服务器**: Go + Gin框架的WebServer
- **上位机系统**: .NET WinCC控制程序
- **数据库**: MySQL 8.0.26

## 许可证

本项目仅供学习和演示使用。