package config

import (
	"encoding/json"
	"io/ioutil"
	"os"
	"path/filepath"
)

type Config struct {
	WebPort    int32  // web 监听端口
	SocketPort int32  // socket 端口号
	DBHost     string // 数据库host
	DBPort     int32  // 数据库端口
	FilePath   string // 文件保存目录
}

var Conf = &Config{
	WebPort:    8080,
	SocketPort: 8000,
	DBHost:     "127.0.0.1",
	DBPort:     3306,
	FilePath:   "upload",
}

func init() {
	str, _ := os.Getwd()
	file := filepath.Join(str, "conf/config.conf")
	if pathExists(file) {
		loadConfig(file, Conf)
	} else {
		paths, _ := filepath.Split(file)
		os.MkdirAll(paths, 0777)
		writeConfig(file, Conf)
	}
}

//判断文件夹是否存在
func pathExists(path string) bool {
	_, err := os.Stat(path)
	if err == nil {
		return true
	}
	if os.IsNotExist(err) {
		return false
	}
	return false
}

//从配置文件中载入json字符串
func loadConfig(path string, config interface{}) error {
	buf, err := ioutil.ReadFile(path)
	if err != nil {
		return err
	}
	err = json.Unmarshal(buf, config)
	if err != nil {
		return err
	}
	return err
}

func writeConfig(path string, config interface{}) error {
	buf, err := json.MarshalIndent(config, "", "    ")
	if err != nil {
		return err
	}

	return ioutil.WriteFile(path, buf, 0777)
}
