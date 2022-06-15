include $(TOPDIR)/rules.mk

PKG_NAME:=modeminfo
PKG_VERSION:=0.3.0
PKG_RELEASE:=0
PKG_MAINTAINER:=Konstantine Shevlakov <shevlakov@132lan.ru>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  PKGARCH:=all
  DEPENDS:=+comgt
  TITLE:=Signal information for 3G/LTE dongle
endef

define Package/$(PKG_NAME)/description
	Signal information for 3G/LTE dongle
endef

define Package/$(PKG_NAME)/conffiles
	/etc/config/modeminfo
endef


define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef


define Package/$(PKG_NAME)/install
	$(CP) ./root/* $(1)/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
