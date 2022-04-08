#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=GoQuiet
PKG_VERSION:=1.2.2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cbeuw/GoQuiet.git
PKG_SOURCE_VERSION:=013cdfdf72000dcd4691799c37a0cf960ab4c82f
PKG_MIRROR_HASH:=c9c97463e5286e8ad10de5e86512b98f60672235c47cfd9696188a16496fc56c

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/cbeuw/GoQuiet
GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define gq/templates
  define Package/$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=A Shadowsocks obfuscation plugin ($(1))
    DEPENDS:=$$(GO_ARCH_DEPENDS) +libpthread
    URL:=https://github.com/cbeuw/GoQuiet
  endef

  define Package/$(1)/description
  A Shadowsocks plugin that obfuscates the traffic as normal HTTPS traffic to non-blocked
  websites through domain fronting and disguises the proxy server as a normal webserver.

  This package contains the $(1).
  endef

  define Package/$(1)/install
	$$(call GoPackage/Package/Install/Bin,$$(PKG_INSTALL_DIR))

	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin/
  endef
endef

GO_PKG_BUILD_VARS += GO111MODULE=auto

GQ_COMPONENTS:=gq-client gq-server

$(foreach component,$(GQ_COMPONENTS), \
  $(eval $(call gq/templates,$(component))) \
  $(eval $(call GoBinPackage,$(component))) \
  $(eval $(call BuildPackage,$(component))) \
)
