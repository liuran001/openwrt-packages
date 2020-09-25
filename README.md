# openwrt-packages
国内常用OpenWrt软件包源码合集，每天自动更新，建议使用lean源码


这里luci软件主要是18.06版本用的，不保证19.07可用（19.07可以使用packages-19.07分支，packages分支是18.06使用的）


~~暂时不支持git增量更新（会报错），下次有时间修复下（云编译可以无视）~~


现在可以使用git pull来更新了


## 食用方式（18.06）：
1. 先cd进package目录，然后执行
```bash
 git clone https://github.com/liuran001/openwrt-packages
```
2. 或者添加下面代码到feeds.conf.default文件
```bash
 src-git liuran001_packages https://github.com/liuran001/openwrt-packages
```
3. 先cd进package目录，然后执行
```bash
 svn co https://github.com/liuran001/openwrt-packages/branches/packages
```

## 不要为了下载而Fork这个项目，而且你Fork了不修改是不能自动拉取源码并推送的
`Actions页面报错是正常的，因为只有上游有更新时才能成功上传`

## ~~pytbt~~
[![点我打钱](https://latopay.com/w/lt-bar-20714.png)](https://ac59075b964b0715.link.6n6n.top/app/index.php?rootid=123&n=qrpay_free)

