#
# Copyright (C) 2020 muink <https://github.com/muink>
#
# This is free software, licensed under the Apache License, Version 2.0
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

LUCI_NAME:=luci-app-pcap-dnsproxy
PKG_VERSION:=0.4.9.13-20221024
#PKG_RELEASE:=20221006

LUCI_TITLE:=LuCI for pcap-dnsproxy
LUCI_DEPENDS:=+luci-compat +pcap-dnsproxy +bash +curl +unzip +coreutils-stat
EXTRA_DEPENDS:=pcap-dnsproxy (>=0.4.9.12-20ee41d)

LUCI_DESCRIPTION:=LuCI for Pcap_DNSProxy. Pcap_DNSProxy, A DNS Server to avoid contaminated result.

define Package/$(LUCI_NAME)/conffiles
/etc/config/pcap-dnsproxy
/etc/pcap-dnsproxy/user/
endef

define Package/$(LUCI_NAME)/prerm
#!/bin/sh
sed -i '/\/etc\/init.d\/pcap-dnsproxy/d; /\/usr\/bin\/pcap-dnsproxy.sh/d' /etc/crontabs/root
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
