

# ------------------- VSSR一键更新脚本！ ------------------- 
wget -4 -O /usr/lib/lua/luci/controller/vssr.lua https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/controller/vssr.lua && chmod 644 /usr/lib/lua/luci/controller/vssr.lua

wget -4 -O /usr/lib/lua/luci/model/cbi/vssr/advanced.lua https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/model/cbi/vssr/advanced.lua && chmod 644 /usr/lib/lua/luci/model/cbi/vssr/advanced.lua

wget -4 -O /usr/lib/lua/luci/model/cbi/vssr/client-config.lua https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/model/cbi/vssr/client-config.lua && chmod 644 /usr/lib/lua/luci/model/cbi/vssr/client-config.lua

wget -4 -O /usr/lib/lua/luci/model/cbi/vssr/client.lua https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/model/cbi/vssr/client.lua && chmod 644 /usr/lib/lua/luci/model/cbi/vssr/client.lua

wget -4 -O /usr/lib/lua/luci/model/cbi/vssr/control.lua https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/model/cbi/vssr/control.lua && chmod 644 /usr/lib/lua/luci/model/cbi/vssr/control.lua

wget -4 -O /usr/lib/lua/luci/model/cbi/vssr/server-config.lua https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/model/cbi/vssr/server-config.lua && chmod 644 /usr/lib/lua/luci/model/cbi/vssr/server-config.lua

wget -4 -O /usr/lib/lua/luci/model/cbi/vssr/server.lua https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/model/cbi/vssr/server.lua && chmod 644 /usr/lib/lua/luci/model/cbi/vssr/server.lua

wget -4 -O /usr/lib/lua/luci/model/cbi/vssr/servers-list.lua https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/model/cbi/vssr/servers-list.lua && chmod 644 /usr/lib/lua/luci/model/cbi/vssr/servers-list.lua

wget -4 -O /usr/lib/lua/luci/model/cbi/vssr/servers.lua https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/model/cbi/vssr/servers.lua && chmod 644 /usr/lib/lua/luci/model/cbi/vssr/servers.lua

wget -4 -O /usr/lib/lua/luci/model/cbi/vssr/status.lua https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/model/cbi/vssr/status.lua && chmod 644 /usr/lib/lua/luci/model/cbi/vssr/status.lua

wget -4 -O /usr/lib/lua/luci/model/cbi/vssr/subscription.lua https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/model/cbi/vssr/subscription.lua && chmod 644 /usr/lib/lua/luci/model/cbi/vssr/subscription.lua

wget -4 -O /usr/lib/lua/luci/model/cbi/shadowsocksr/client.lua https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/client.lua && chmod 644 /usr/lib/lua/luci/model/cbi/shadowsocksr/client.lua
								 
wget -4 -O /usr/lib/lua/luci/view/vssr/ssrurl.htm https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/view/vssr/ssrurl.htm && chmod 644 /usr/lib/lua/luci/view/vssr/ssrurl.htm

wget -4 -O /usr/lib/lua/luci/view/vssr/status.htm https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/view/vssr/status.htm && chmod 644 /usr/lib/lua/luci/view/vssr/status.htm

wget -4 -O /usr/lib/lua/luci/view/vssr/status1.htm https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/view/vssr/status1.htm && chmod 644 /usr/lib/lua/luci/view/vssr/status1.htm

wget -4 -O /usr/lib/lua/luci/view/vssr/status2.htm https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/view/vssr/status2.htm && chmod 644 /usr/lib/lua/luci/view/vssr/status2.htm

wget -4 -O /usr/lib/lua/luci/view/vssr/status3.htm https://raw.githubusercontent.com/LEDBO/tomato/master/luasrc/view/vssr/status3.htm && chmod 644 /usr/lib/lua/luci/view/vssr/status3.htm

wget -4 -O /usr/lib/lua/luci/i18n/vssr.zh-cn.lmo  https://raw.githubusercontent.com/LEDBO/tomato/master/po/zh-cn/vssr.zh-cn.lmo && chmod 644 /usr/lib/lua/luci/i18n/vssr.zh-cn.lmo

wget -4 -O /etc/init.d/vssr https://raw.githubusercontent.com/LEDBO/tomato/master/root/etc/init.d/vssr && chmod 775 /etc/init.d/vssr

wget -4 -O /usr/bin/vssr-switch https://raw.githubusercontent.com/LEDBO/tomato/master/root/usr/bin/vssr-switch && chmod 755 /usr/bin/vssr-switch

wget -4 -O /usr/bin/vssr-monitor https://raw.githubusercontent.com/LEDBO/tomato/master/root/usr/bin/vssr-monitor && chmod 755 /usr/bin/vssr-monitor

wget -4 -O /usr/bin/vssr-rules https://raw.githubusercontent.com/LEDBO/tomato/master/root/usr/bin/vssr-rules && chmod 755 /usr/bin/vssr-rules

wget -4 -O /usr/share/vssr/subscribe.lua https://raw.githubusercontent.com/LEDBO/tomato/master/root/usr/share/vssr/subscribe.lua && chmod 664 /usr/share/vssr/subscribe.lua

wget -4 -O /www/luci-static/vssr/css/vssr.css https://raw.githubusercontent.com/LEDBO/tomato/master/root//www/luci-static/vssr/css/vssr.css  && chmod 0644 /www/luci-static/vssr/css/vssr.css

wget -4 -O /etc/config/vssr https://raw.githubusercontent.com/LEDBO/tomato/master/root/etc/config/vssr && chmod 600 /etc/config/vssr

wget -4 -O /usr/bin/v2ray/v2ctl https://raw.githubusercontent.com/LEDBO/tomato/master/v2ray/v2ctl && chmod 755 /usr/bin/v2ray/v2ctl

wget -4 -O /usr/bin/v2ray/v2ray  https://raw.githubusercontent.com/LEDBO/tomato/master/v2ray/v2ray && chmod 755 /usr/bin/v2ray/v2ray

wget -4 -O /usr/sbin/trojan  https://raw.githubusercontent.com/LEDBO/tomato/master/v2ray/trojan && chmod 755 /usr/sbin/trojan

		
-------------------Hello World 版本更新成功！ ------------------- >> -------------------v2ray/trojan二进制更新完成！ ------------------- >> 
