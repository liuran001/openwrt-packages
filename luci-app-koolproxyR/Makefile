include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-koolproxyR
PKG_VERSION:=3.8.5
PKG_RELEASE:=1-20201105

PKG_MAINTAINER:=panda-mute <wxuzju@gmail.com>
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

RSTRIP:=true

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-koolproxyR
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI support for koolproxyR
	DEPENDS:=+openssl-util +ipset +dnsmasq-full +@BUSYBOX_CONFIG_DIFF +iptables-mod-nat-extra +wget
	MAINTAINER:=panda-mute
endef

define Package/luci-app-koolproxyR/description
	This package contains LuCI configuration pages for koolproxy.
endef

define Build/Compile
endef

define Package/luci-app-koolproxyR/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	( . /etc/uci-defaults/luci-koolproxy ) && rm -f /etc/uci-defaults/luci-koolproxy
	rm -f /tmp/luci-indexcache
fi
exit 0
endef

define Package/luci-app-koolproxyR/conffiles
	/etc/config/koolproxy
	/usr/share/koolproxy/data/rules/
endef

define Package/luci-app-koolproxyR/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/
	cp -pR ./root/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/koolproxy.po $(1)/usr/lib/lua/luci/i18n/koolproxy.zh-cn.lmo

ifeq ($(ARCH),mipsel)
	$(INSTALL_BIN) ./bin/mipsel $(1)/usr/share/koolproxy/koolproxy
endif
ifeq ($(ARCH),mips)
	$(INSTALL_BIN) ./bin/mips $(1)/usr/share/koolproxy/koolproxy
endif
ifeq ($(ARCH),x86)
	$(INSTALL_BIN) ./bin/x86 $(1)/usr/share/koolproxy/koolproxy
endif
ifeq ($(ARCH),x86_64)
	$(INSTALL_BIN) ./bin/x86_64 $(1)/usr/share/koolproxy/koolproxy
endif
ifeq ($(ARCH),arm)
	$(INSTALL_BIN) ./bin/arm $(1)/usr/share/koolproxy/koolproxy
endif
ifeq ($(ARCH),aarch64)
	$(INSTALL_BIN) ./bin/aarch64 $(1)/usr/share/koolproxy/koolproxy
endif
endef

$(eval $(call BuildPackage,luci-app-koolproxyR))
