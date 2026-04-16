package models

import (
	"os"
	"path/filepath"
	"time"
	"webserver/src/config"

	_ "modernc.org/sqlite"
	"xorm.io/xorm"
	"xorm.io/xorm/log"
)

type DBClient struct {
	engine *xorm.Engine
}

var DB = &DBClient{engine: nil}

func (db *DBClient) Open() error {
	var err error
	dbPath := config.Conf.DBPath
	// 确保数据库文件所在目录存在
	dir := filepath.Dir(dbPath)
	if dir != "" && dir != "." {
		os.MkdirAll(dir, 0777)
	}
	db.engine, err = xorm.NewEngine("sqlite", dbPath)
	if err != nil {
		return err
	}
	db.engine.SetLogLevel(log.LOG_DEBUG)
	db.engine.ShowSQL(true)
	db.engine.SetMaxIdleConns(10)
	db.engine.SetMaxOpenConns(10)
	db.engine.SetTZDatabase(time.Local)
	db.engine.SetTZLocation(time.Local)
	return nil
}

func (db *DBClient) Sync() error {
	return db.engine.Sync2(new(Device), new(DeviceRecord), new(OperateRecord))
}

func init() {
	err := DB.Open()
	if err != nil {
		return
	}
	DB.Sync()
}
