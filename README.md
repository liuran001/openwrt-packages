# openwrt-packages
国内常用OpenWrt软件包源码合集，每天自动更新，建议使用lean源码


这里luci软件主要是18.06版本用的，不保证19.07可用


## 食用方式：
1、 先cd进package目录，然后执行  
```bash
 git clone https://github.com/liuran001/openwrt-packages
```
2、 或者添加下面代码到feeds.conf.default文件  
```bash
 src-git liuran001_packages https://github.com/liuran001/openwrt-packages
```
我本人建议使用第一种  
云编译也同理
