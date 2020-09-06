# luci-app-vssr-plus
a new SSR SS V2ray luci app bese luci-app-ssr-plus

#### 此项目不在更新如需更新请使用内置一键更新脚本完成

#### Intro
写在前面：插件改名的原因并非是要另起炉灶，主要是自己想要的功能【视觉体验优先】，和原版略有差异，而且插件体积越来越大，并不适合小ROM机器使用。

1.基于lean ssr+ 全新修改的Vssr（更名为Hello World） 主要做了很多的修改和优化，同时感谢插件原作者所做出的的努力和贡献！

2.节点列表支持国旗显示 ，节点列表页面 打开自动ping.

3.优化了在节点列表页面点击应用后节点切换的速度。同时也优化了自动切换的速度。

4.给Hello World 增加了IP状态显示，在页面底部 左边显示当前节点国旗 ip 和中文国家 右边 是四个网站的访问状态  可以访问是彩色 不能访问是灰色。

5.优化了国旗匹配方法，在部分带有emoji counrty code的节点名称中 优先使用 emoji code 匹配国旗。

6.建议搭配opentomato  opentomcat Butterfly  theme，能有最好的显示体验。

新修改插件难免有bug 请不要大惊小怪。欢迎提交bug。

###  修正与lean原版冲突文件可以同时编译


#### 感谢
https://github.com/coolsnowwolf/lede

#### My other project
Argon theme ：https://github.com/Leo-Jo-My/luci-theme-argon-mod   

theme : https://github.com/Leo-Jo-My/luci-theme-opentomato

theme : https://github.com/Leo-Jo-My/luci-theme-opentomcat

theme : https://github.com/Leo-Jo-My/luci-theme-Butterfly

theme : https://github.com/Leo-Jo-My/luci-theme-Butterfly-dark

### luci-theme-Butterfly已完美适配（除部分主题显示不正常外适用大部分主题）

### 说明

源码来源：https://github.com/jerrykuku/luci-app-vssr


### 使用方法
```Brach
    #下载源码
    
    git clone https://github.com/Leo-Jo-My/luci-app-vssr-plus package/luci-app-vssr-plus
    
    git clone https://github.com/Leo-Jo-My/my package/my  #依赖包
    
    make menuconfig
    
    #编译
    
    make package/luci-app-vssr/{clean,compile} V=s


