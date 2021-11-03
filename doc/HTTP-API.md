
-----------------------------------------------------------------
## App与服务器通信  HTTP

------------------------------------------------------------------------------------------------

### 1、record接口

##### 备注:请求为POST

#### 1.1 App发给服务器的操作命令(json)

服务器接口地址: 

```http
http://112.74.182.249/record
```

按照data顺序解释:

操作命令:1 //固定值，其余几个均为参数
上位机ID:1
上位机运行模式(手动模式/自动模式):1
从站地址(风机编号):33
输入源选择:3
运行模式: 1
风量等级:3 
设置转速:1000

例:

```json
{
    "operate": "1",
    "socket_client": "1",
    "socket_client_model": "1",
    "address": "33",
    "source": "3",
    "mode": "1",
    "level": "3",
    "rot_speed": "1000"
}
```

服务器存储后发给上位机 格式 :00 00 00 01 01 21 41 01 00 06 03 01 00 03 0A 00 xx xx(最后两位为校验码)

解释详见上位机与服务器通信协议(TCP接口)

#### 1.2 服务器对record接口的回复

```json
{
    "code": 0,
    "msg": "success",
    "data": null
}
```

### 2、query接口

##### 备注:请求为POST

#### 2.1 App发给服务器的查询请求(json)

服务器接口地址: 

```http
http://112.74.182.249/query
```

查询命令:1 //固定值，其余几个均为参数
上位机ID:1
从站地址(风机编号):33

```json
{
    "check": "1",
    "socket_client": "1",
    "address": "33"
}
```

#### 2.2、服务器对query接口的回复(注意是json对象，不是json字符串)
按照data顺序解释:

上位机网络状态

上位机ID
从站地址(风机编号)
当前状态
当前故障
输入源
运行模式
风机转速
NTC温度
母线电压
U相电流
V相电流
W相电流

x轴加速度
y轴加速度
z轴加速度
加速度矢量和

已运行时间
软件版本
数据刷新时间
例:

```json
{
    "code": 0,
    "msg": "OK",
    "data": {
        "online_status": "0",
        "socket_client": "1",
        "address": "33",
        "status": "空闲",
        "fault": "无故障",
        "source": "DC 110V",
        "mode": "设置转速",
        "rot_speed": "0",
        "ntc_temp": "34",
        "bus_voltage": "297",
        "u_current": "0",
        "v_current": "0",
        "w_current": "0",
        "x_acceleration": "0",
        "y_acceleration": "0",
        "z_acceleration": "0",
        "sum_acceleration": "0",
        "run_time": "11281",
        "version": "V1.00",
        "now_time": "2021-08-23 16:30:25 +0800 CST"
    }
}
```

### 3 上位机在线查询接口online

##### 备注:请求为POST

接口地址:

```http
http://112.74.182.249/online
```

#### 3.1 App请求

3.1.2 上位机ID由服务器分配

```json
{
    "socket_client": "all"
}
```

#### 3.2服务器回复

```json
{
    "code": 0,
    "msg": "OK",
    "data_list": [
        {
            "socket_client": "1",
            "online_status": "1",
            "name":"PMSM上位机1",
            "description":"PMSM上位机1-设备列表"
        },
        {
            "socket_client": "2",
            "online_status": "1",
            "name":"PMSM上位机2",
            "description":"PMSM上位机2-设备列表"
        }
    ]
}
```

### 4、设备在线查询接口online_inside

##### 备注:请求为POST

```http
http://112.74.182.249/online_inside
```

#### 4.1 App请求

4.1.2 例1  上位机1内部设备查询

```json
{
    "socket_client": "1"
} 
```

#### 4.2 服务器回复

```json
 {
    "code": 0,
    "msg": "OK",
    "data_list": [
        {
            "address": "33",
            "address_online_status": "1"
        },
        {
            "address": "34",
            "address_online_status": "1"
        },
        {
            "address": "35",
            "address_online_status": "1"
        },
        {
            "address": "36",
            "address_online_status": "1"
        },
        {
            "address": "37",
            "address_online_status": "1"
        },
        {
            "address": "38",
            "address_online_status": "1"
        },
        {
            "address": "39",
            "address_online_status": "1"
        },
        {
            "address": "40",
            "address_online_status": "1"
        }
    ]
}
```

### 5、版本更新检测接口version

##### 备注:请求为POST

```http
http://112.74.182.249/version
```

请求:

```json
{
    "version": "1.1.1"
}
```

回复

```json
{
    "code": 0,
    "msg": "OK",
    "data": {
        "version": "1.1.2",
        "url": "/download/android_1.1.2.apk"
    }
}
```

