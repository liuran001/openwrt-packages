# openwrt-packages
国内常用OpenWrt软件包源码合集，每天自动更新，建议使用lean源码


18.06版luci请使用packages分支


19.07版luci请使用packages-19.07分支

`lean源码用主分支，op官方源码用packages-19.07`

## 有问题请发issue，我不上恩山的！！！
请求加入xxx软件包/问题反馈也请使用issue

### 更新日志
`2021/3/13`
- 添加uu加速器，修改adguardhome的luci来源（原作者长期未更新，存在大量问题）
- ~~证明我还活着~~


## 食用方式（三选一，这里以18.06为例）：
`还是建议按需取用，不然碰到依赖问题不太好解决`
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

## 不要为了下载而Fork这个项目

## 支持一下？（推荐使用支付宝）
[点我打钱](https://ac59075b964b0715.link.6n6n.top/app/index.php?rootid=123&n=qrpay_free)

