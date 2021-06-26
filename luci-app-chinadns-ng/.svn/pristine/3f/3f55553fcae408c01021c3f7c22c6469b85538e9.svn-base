# LuCI Interface for ChinaDNS Next Generation for OpenWrt

## 简介

本项目为 [openwrt-chinadns-ng](https://github.com/pexcn/openwrt-chinadns-ng) 提供 LuCI 接口。

## 编译

从 OpenWrt 的 [SDK](https://openwrt.org/docs/guide-developer/obtain.firmware.sdk) 编译
```bash
cd openwrt-sdk

# 获取源码
git clone -b luci https://github.com/pexcn/openwrt-chinadns-ng.git package/luci-app-chinadns-ng

# 选中 LuCI -> Applications -> luci-app-chinadns-ng
make menuconfig

# 编译 luci-app-chinadns-ng
make package/luci-app-chinadns-ng/{clean,compile} V=s
```

## 鸣谢

- [@zfl9/chinadns-ng](https://github.com/zfl9/chinadns-ng)
- [@aa65535/openwrt-chinadns](https://github.com/aa65535/openwrt-chinadns)
