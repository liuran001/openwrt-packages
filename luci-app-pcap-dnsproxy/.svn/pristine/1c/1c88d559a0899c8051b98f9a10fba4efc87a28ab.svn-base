OpenWrt/LEDE LuCI for Pcap-DNSProxy
===

说明
---

此项目是 pcap-dnsproxy 在 OpenWrt/LEDE 上 LuCI 界面  
pcap-dnsproxy 是一个专注于在标准 DNS 协议下，过滤污染拿到正确解析的工具，相较其他方案（DoT DoH）拥有更快的响应速度，但在不正确的配置下仍容易被污染（使用不可靠协议进行解析）  
以 pcap-dnsproxy 0.4.9.13-70a40bb 作为基点开发，为了保持配置文件的兼容性，建议也使用这个版本的 pcap-dnsproxy  

依赖
---

`luci-compat` `pcap-dnsproxy >= 0.4.9.12-20ee41d` `bash` `curl` `unzip` `coreutils-stat`

编译
---

 - 从 OpenWrt/LEDE 的 SDK 编译

   ```bash
   # 以 ar71xx 平台为例，此处文件名为示例，仅供参考，请以实际文件名为准
   # 有对应平台的 SDK 即可编译软件包，不仅限于 ar71xx
   tar xjf OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2
   # 进入 SDK 根目录
   cd OpenWrt-SDK-ar71xx-*
   # 先运行一遍以生成 .config 文件
   make menuconfig
   ./scripts/feeds update -a
   ./scripts/feeds install -a
   # 获取 Makefile
   git clone --depth 1 --branch master --single-branch https://github.com/muink/luci-app-pcap-dnsproxy.git package/luci-app-pcap-dnsproxy
   # 为两个可执行文件赋权
   pushd package/luci-app-pcap-dnsproxy
   chmod 0755 ./root/etc/uci-defaults/40_luci-pcap-dnsproxy
   chmod 0755 ./root/usr/bin/pcap-dnsproxy.sh
   popd
   # 选择要编译的包 LuCI -> Applications -> luci-app-pcap-dnsproxy 并进行个人定制，或者保持默认
   make menuconfig
   # 编译依赖 pcap-dnsproxy
   # 请参考 https://github.com/wongsyrone/openwrt-Pcap_DNSProxy
   # 正式开始编译
   make package/luci-app-pcap-dnsproxy/compile V=99
   # 编译结束之后从 bin 文件夹复制本程序的 ipk 文件到设备中，使用 opkg 进行安装
   ```

安装
---

安装前建议完全卸载 pcap-dnsproxy 并清空其配置文件，具体操作如下

   ```bash
   opkg remove --force-removal-of-dependent-packages pcap-dnsproxy
   rm -f /etc/config/pcap-dnsproxy 2>/dev/null
   rm -rf /etc/pcap-dnsproxy/ 2>/dev/null
   ```

之后安装 `pcap-dnsproxy` `luci-app-pcap-dnsproxy` `luci-i18n-pcap-dnsproxy-zh-cn`  
完成后设置 dnsmasq 转发请求到 pcap-dnsproxy

   ```bash
   uci add_list dhcp.@dnsmasq[0].server='::1#1053'
   uci add_list dhcp.@dnsmasq[0].server='127.0.0.1#1053'
   uci commit dhcp
   /etc/init.d/dnsmasq restart
   ```

检查 `/tmp/resolv.conf` 和 `/tmp/resolv.conf.auto` 如果存在自动获取的dns  
则需要关闭 wan 口的 '自动获取dns'

   ```bash
   uci set network.wan.peerdns='0'
   uci set network.wan6.peerdns='0'
   uci set dhcp.@dnsmasq[0].noresolv='1'
   uci commit dhcp
   uci commit network
   /etc/init.d/dnsmasq restart
   ifup wan
   ```

