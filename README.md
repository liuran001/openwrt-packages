# openwrt-packages
国内常用OpenWrt软件包源码合集，每天自动更新，建议使用lean源码


这里luci软件主要是18.06版本用的，不保证19.07可用


暂时不支持git增量更新（会报错），下次有时间修复下（云编译可以无视）


建议用svn方式拉取


## 食用方式：
1. 先cd进package目录，然后执行（建议云编译使用这种方式）
```bash
 git clone https://github.com/liuran001/openwrt-packages
```
2. 或者添加下面代码到feeds.conf.default文件（建议本地编译使用这种方式）
```bash
 src-git liuran001_packages https://github.com/liuran001/openwrt-packages
```
3. 先cd进package目录，然后执行
```bash
 svn co https://github.com/liuran001/openwrt-packages/branches/packages
```

## 不要为了下载而Fork这个项目，而且你Fork了不修改是不能自动拉取源码的

