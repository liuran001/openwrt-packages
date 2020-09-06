include $(TOPDIR)/rules.mk

PKG_NAME:=3proxy
PKG_VERSION:=0.9-devel

PKG_MAINTAINER:=muziling <lls924@gmail.com>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/z3APA3A/3proxy.git
PKG_SOURCE_VERSION:=cc503ba9252ba4197d48a520189fb04289329c2c

PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk

define Package/3proxy
  SUBMENU:=Web Servers/Proxies
  SECTION:=net
  CATEGORY:=Network
  TITLE:=3proxy OpenWRT package
  DEPENDS:=+libpthread +libopenssl
endef

define Package/lib3proxy
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=+3proxy
  TITLE:=3proxy libraries
endef

define Package/3proxy-servers
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=+3proxy
  TITLE:=3proxy addional servers
endef

define Package/3proxy-sql
  PKGARCH:=all
  DEPENDS:=+3proxy
  TITLE:=3proxy sql template
endef

define Package/$(PKG_NAME)/description
	3APA3A 3proxy tiny proxy servers
endef

define Build/Configure
	$(CP) $(PKG_BUILD_DIR)/Makefile.Linux $(PKG_BUILD_DIR)/Makefile
endef

define Package.$(PKG_NAME)/conffiles
	/etc/config/3proxy
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/3proxy \
			$(PKG_BUILD_DIR)/bin/proxy \
			$(1)/usr/bin/
	$(CP) ./files/* $(1)/
endef

define Package/lib$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/3proxy
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/*.so $(1)/usr/lib/3proxy
endef

define Package/$(PKG_NAME)-servers/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/ftppr \
	$(PKG_BUILD_DIR)/bin/mycrypt \
		$(PKG_BUILD_DIR)/bin/pop3p \
		$(PKG_BUILD_DIR)/bin/smtpp \
		$(PKG_BUILD_DIR)/bin/tcppm \
		$(PKG_BUILD_DIR)/bin/udppm \
		$(1)/usr/bin
endef

define Package/$(PKG_NAME)-sql/install
	$(INSTALL_DIR) $(1)/usr/share/3proxy
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cfg/sql/* $(1)/usr/share/3proxy
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,lib$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)-servers))
$(eval $(call BuildPackage,$(PKG_NAME)-sql))

