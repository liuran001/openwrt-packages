## luci-app-vssr [Hello World]
A new SSR SS V2ray Trojan luci app bese luci-app-ssr-plus  
<b>支持全部类型的节点分流</b>  
目前只适配最新版 argon主题 （其他主题下应该也可以用 但显示应该不会很完美）
目前Lean最新版本的openwrt 已经可以直接拉取源码到 package/lean 下直接进行勾选并编译。  


### Update Log 2020-12-05  v1.19

#### Updates

- FIX: 修复了白名单模式下可能变成全局的问题。
- UPDATE: 提高白名单列表更新速度。
- UPDATE: 服务器列表采用新的排序方式(按字母顺序)。
- UPDATE: 优化节点列表加载速度并改进排序显示，现在几乎秒加载。
- DELETE: 删除许可页面。

详情见[具体日志](./relnotes.txt)。 

### Intro

1. 基于lean ssr+ 全新修改的Vssr（更名为Hello World） 主要做了很多的修改，同时感谢插件原作者所做出的的努力和贡献！ 
1. 节点列表支持国旗显示 TW节点为五星红旗， 节点列表页面 打开自动ping.  
1. 优化了在节点列表页面点击应用后节点切换的速度。同时也优化了自动切换的速度。  
1. 将节点订阅转移至 高级设置 请悉知 由于需要获取ip的国家code 新的订阅速度可能会比原来慢一点点 x86无影响。  
1. 给Hello World 增加了IP状态显示，在页面底部 左边显示当前节点国旗 ip 和中文国家 右边 是四个网站的访问状态  可以访问是彩色不能访问是灰色。  
1. 优化了国旗匹配方法，在部分带有emoji counrty code的节点名称中 优先使用 emoji code 匹配国旗。  
1. 建议搭配argon theme，能有最好的显示体验。  

新修改插件难免有bug 请不要大惊小怪。欢迎提交bug。

### How to use
假设你的lean openwrt（最新版本19.07） 在 lede 目录下
```
cd lede/package/lean/  

git clone https://github.com/jerrykuku/lua-maxminddb.git  #git lua-maxminddb 依赖

git clone https://github.com/jerrykuku/luci-app-vssr.git  

make menuconfig

make -j1 V=s
```

### 感谢
https://github.com/coolsnowwolf/lede

### My other project
Argon theme ：https://github.com/jerrykuku/luci-theme-argon 
京东签到插件 ：https://github.com/jerrykuku/luci-app-jd-dailybonus 
openwrt-nanopi-r1s-h5 ： https://github.com/jerrykuku/openwrt-nanopi-r1s-h5
