include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-chinadns-ng
PKG_VERSION:=1.1
PKG_RELEASE:=6

LUCI_TITLE:=LuCI support for chinadns-ng
LUCI_DESCRIPTION:=LuCI Support for chinadns-ng.
LUCI_DEPENDS:=+chinadns-ng
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

define Package/chinadns-ng/conffiles
/etc/config/chinadns-ng
/etc/chinadns-ng/chnroute.txt
/etc/chinadns-ng/chnroute6.txt
/etc/chinadns-ng/gfwlist.txt
/etc/chinadns-ng/chinalist.txt
/etc/chinadns-ng/whitelist.txt
/etc/chinadns-ng/blacklist.txt
endef

# call BuildPackage - OpenWrt buildroot signature
