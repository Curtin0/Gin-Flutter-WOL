package models

import (
	"fmt"
	"time"
	"webserver/src/config"

	_ "github.com/go-sql-driver/mysql"
	"github.com/go-xorm/xorm"
	"xorm.io/core"
)

type DBClient struct {
	engine *xorm.Engine
}

var DB = &DBClient{engine: nil}

// "username:password@tcp(ip:port)/database?charset=utf8
func (db *DBClient) Open() error {
	var err error
	sourcename := fmt.Sprintf("%v:%v@tcp(%v:%v)/webserver?charset=utf8", "root", "ASIM01@2021.tongye", config.Conf.DBHost, config.Conf.DBPort)
	db.engine, err = xorm.NewEngine("mysql", sourcename)
	if err != nil {
		return err
	}
	db.engine.SetLogLevel(core.LOG_DEBUG)

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
