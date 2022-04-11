package controllers

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"webserver/src/config"

	"github.com/gin-gonic/gin"
)

type VersionInfo struct {
	Version string `json:"version"`
	Url     string `json:"url"`
}

type IVersion struct {
	Major    int32 // 主版本
	Minor    int32 // 子版本
	Revision int32 // 修正版本
}

type VersionResponse struct {
	Code int32       `json:"code"`
	Msg  string      `json:"msg"`
	Data VersionInfo `json:"data"`
}

func versionToIVersion(version string) *IVersion {
	nums := strings.Split(version, ".")
	if len(nums) >= 3 {
		res := &IVersion{
			Major:    0,
			Minor:    0,
			Revision: 0,
		}
		res.Major = string2Int32(nums[0])
		res.Minor = string2Int32(nums[1])
		res.Revision = string2Int32(nums[2])
		return res
	}
	return nil
}

// 判断 a 版本是否比 b 版本新 a服务器 bApp
func isNewer(a *IVersion, b *IVersion) bool {
	if a.Major > b.Major {
		return true
	} else if a.Major == b.Major {
		if a.Minor > b.Minor {
			return true
		} else if a.Minor == b.Minor {
			if a.Revision > b.Revision {
				return true
			} else if a.Revision == b.Revision {
				return true
			}
		}
	}
	return false
}

func Download(ctx *gin.Context) {
	filename := ctx.Param("filename")

	ctx.FileAttachment(filepath.Join(config.Conf.FilePath, filename), filename)
}

func Version(ctx *gin.Context) {
	var version VersionInfo

	if err := ctx.ShouldBindJSON(&version); err != nil {
		ctx.JSON(http.StatusOK, VersionResponse{
			Code: -1,
			Msg:  err.Error(),
		})
		return
	}

	ivers := versionToIVersion(version.Version)
	if ivers == nil {
		ctx.JSON(http.StatusOK, VersionResponse{
			Code: -1,
			Msg:  fmt.Sprintf("version[%v] parse error", version.Version),
		})
		return
	}
	var dir string
	if filepath.IsAbs(config.Conf.FilePath) {
		dir = config.Conf.FilePath
	} else {
		curdir, _ := os.Getwd()
		dir = filepath.Join(curdir, config.Conf.FilePath)
	}

	rd, err := ioutil.ReadDir(dir)
	if err != nil {
		ctx.JSON(http.StatusOK, QueryReponse{
			Code: -2,
			Msg:  fmt.Sprintf("ReadDir dir:%v err:%v", dir, err),
		})
		return
	}

	// 查找最新版本
	var headVersion *IVersion
	var vfilename string
	for _, file := range rd {
		if file.IsDir() {
			continue
		} else {
			// 文件命名规范 xxxxxxx_1.1.1.apk
			filename := file.Name()
			suffix := filepath.Ext(filename)
			prefix := filename[0 : len(filename)-len(suffix)]
			names := strings.Split(prefix, "_")
			if len(names) >= 2 {
				str := names[len(names)-1]
				ver := versionToIVersion(str)
				if ver != nil {
					if headVersion != nil {
						if isNewer(ver, headVersion) {
							headVersion = ver
							vfilename = filename
						}
					} else {
						headVersion = ver
						vfilename = filename
					}
				}
			}
		}
	}
	res := &VersionResponse{
		Code: 0,
		Msg:  "OK",
	}
	if headVersion != nil && isNewer(headVersion, ivers) {
		res.Data = VersionInfo{
			Version: fmt.Sprintf("%d.%d.%d", headVersion.Major, headVersion.Minor, headVersion.Revision),
			Url:     "/download/" + vfilename,
		}
	}
	ctx.JSON(http.StatusOK, res)
}
