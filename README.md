## 项目架构

### 1.1 项目框架图

![Gin-Flutter-Pmsm.png](https://i.loli.net/2021/09/18/vJnr241HQMTZoAy.png)

<div align=center>
<img src="https://img.shields.io/badge/VS Code-blue"/>
<img src="https://img.shields.io/badge/golang-1.16.5-blue"/>
<img src="https://img.shields.io/badge/gin-1.7.2-lightBlue"/>
<img src="https://img.shields.io/badge/flutter-2.0.5-brightgreen"/>
<img src="https://img.shields.io/badge/.NET-5-lightgreen"/>
<img src="https://img.shields.io/badge/mysql-8.0.26-lightgreen"/>
<img src="https://img.shields.io/badge/xorm-0.7.9-red"/>
</div>



### 1.2 源代码目录结构

```
 [服务器]
    ├─WebServer          （后端文件夹）
     └─doc               （接口文档）
     └─src 	             （源码包）
       ├─config          （配置包）
       ├─controllers  	 （后端內核）★
       ├─httpserver      （http通信服务）
       ├─models          （数据库服务）
       ├─net             （tcp通信服务）
       ├─routers         （路由）
     └─upload 	         （App安装包资源）
  [App]
    ├─AppGUI             （前端文件夹）
     └─lib               （源码包）
       ├─api             （http通信接口）
       ├─base            （通信数据格式框架）
       ├─components      （通用组件）
       ├─fan_controllers （前端内核）★
       ├─more            （说明页面）
  [上位机]
    ├─WinCC              （上位机文件夹）
     └─PortCMD...        （上位机控制程序）
     └─PortCMD.WinForm   （上位机界面）
```

