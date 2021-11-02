package main

import (
	"webserver/src/httpserver"
	_ "webserver/src/sysinit"
)

func main() {
	httpserver.Run()
}
