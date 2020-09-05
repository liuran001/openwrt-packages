#!/bin/bash
svn co https://github.com/kenzok8/openwrt-packages/trunk/adguardhome
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/gost
svn co https://github.com/rufengsuixing/luci-app-adguardhome/trunk ./luci-app-adguardhome
svn co https://github.com/project-openwrt/openwrt/trunk/package/ntlf9t/luci-app-advancedsetting
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-app-aliddns
svn co https://github.com/frainzy1477/luci-app-clash/trunk ./luci-app-clash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash
svn co https://github.com/garypang13/luci-app-eqos/trunk ./luci-app-eqos
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-app-gost
svn co https://github.com/jerrykuku/luci-app-jd-dailybonus/trunk ./luci-app-jd-dailybonus
svn co https://github.com/jerrykuku/luci-theme-argon/branches/18.06 ./luci-theme-argon
svn co https://github.com/jerrykuku/luci-app-vssr/trunk ./luci-app-vssr
svn co https://github.com/tty228/luci-app-serverchan/trunk ./luci-app-serverchan
svn co https://github.com/fw876/helloworld/trunk ./
rm -rf .svn
svn co https://github.com/xiaorouji/openwrt-package/trunk/lienol ./
rm -rf .svn
svn co https://github.com/xiaorouji/openwrt-package/trunk/obsolete ./
rm -rf .svn
svn co https://github.com/xiaorouji/openwrt-package/trunk/others ./
rm -rf .svn
svn co https://github.com/xiaorouji/openwrt-package/trunk/package ./
rm -rf .svn
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-app-smartdns
svn co https://github.com/kenzok8/openwrt-packages/trunk/smartdns
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-argon_new
svn co https://github.com/kenzok8/luci-theme-ifit/trunk/luci-theme-ifit
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-atmaterial
svn co https://github.com/garypang13/luci-theme-edge/branches/18.06 ./luci-theme-edge
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-opentomato
svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-theme-opentomcat
svn co https://github.com/jerrykuku/node-request/trunk ./node-request
svn co https://github.com/jerrykuku/lua-maxminddb/trunk ./lua-maxminddb
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-Butterfly-dark
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-Butterfly
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-argon-mc
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-argon-mod
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-argonv2
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-argonv3
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-darkmatter
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-infinityfreedom
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/luci-theme-netgearv2
svn co https://github.com/rosywrt/luci-theme-rosy/trunk/luci-theme-rosy
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/UnblockNeteaseMusic
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/UnblockNeteaseMusicGo
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/adbyby
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/baidupcs-web
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-baidupcs-web
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-adbyby-plus
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-airplay2
svn co https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom/trunk/luci-theme-infinityfreedom
svn co https://github.com/cnzd/luci-app-koolproxyR/trunk ./luci-app-koolproxyR
svn co https://github.com/MiRouter/luci-app-vssr-plus/trunk ./luci-app-vssr-plus
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/GoQuiet
svn co https://github.com/project-openwrt/openwrt/trunk/package/ctcgfw/ChinaDNS
svn co https://github.com/lisaac/luci-app-dockerman/trunk/applications/luci-app-dockerman
svn co https://github.com/lisaac/luci-lib-docker/trunk/collections/luci-lib-docker
svn co https://github.com/lisaac/luci-app-diskman/trunk ./luci-app-diskman
mkdir parted
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O parted/Makefile
svn co https://github.com/destan19/OpenAppFilter/trunk ./
rm -rf .svn
svn co https://github.com/4IceG/luci-app-3ginfo/trunk/luci-app-3ginfo
svn co https://github.com/brvphoenix/luci-app-wrtbwmon/branches/old-master/luci-app-wrtbwmon
svn co https://github.com/riverscn/openwrt-iptvhelper/trunk/iptvhelper
svn co https://github.com/riverscn/openwrt-iptvhelper/trunk/luci-app-iptvhelper
svn co https://github.com/brvphoenix/wrtbwmon/branches/old-master/wrtbwmon
svn co https://github.com/KFERMercer/luci-app-tcpdump/trunk ./luci-app-tcpdump
svn co https://github.com/tty228/luci-app-nodogsplash/trunk ./luci-app-nodogsplash
svn co https://github.com/koshev-msk/luci-app-atinout/trunk ./luci-app-atinout
cp -r ./luci-app-atinout/atinout ./
svn co https://github.com/muink/luci-app-pcap-dnsproxy/branches/dev ./luci-app-pcap-dnsproxy
svn co https://github.com/koshev-msk/3proxy-openwrt/trunk ./3proxy
svn co https://github.com/pexcn/openwrt-chinadns-ng/branches/luci ./luci-app-chinadns-ng
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/luci-app-usb-printer
rm -rf ./*/.svn
rm -f README.md .gitattributes .gitignore
exit 0
