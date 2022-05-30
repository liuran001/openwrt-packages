include $(TOPDIR)/rules.mk

LUCI_TITLE:=Information dashboard for 3G/LTE dongle
LUCI_DEPENDS:=+comgt +luci-compat
PKG_LICENSE:=GPLv3
PKG_VERSION:=0.2.4-0

define Package/luci-app-modeminfo/conffiles
	/etc/config/modeminfo
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
