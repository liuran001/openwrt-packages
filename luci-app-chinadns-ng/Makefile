include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-chinadns-ng
PKG_VERSION:=1.0
PKG_RELEASE:=4

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI support for chinadns-ng
	LUCI_DEPENDS:=+chinadns-ng
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/luasrc/i18n/*.po), \
		po2lmo $(po) ${CURDIR}/luasrc/i18n/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DATA) root/usr/share/rpcd/acl.d/luci-app-chinadns-ng.json $(1)/usr/share/rpcd/acl.d/luci-app-chinadns-ng.json
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ${CURDIR}/luasrc/i18n/*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) luasrc/model/cbi/chinadns-ng.lua $(1)/usr/lib/lua/luci/model/cbi/chinadns-ng.lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) luasrc/controller/chinadns-ng.lua $(1)/usr/lib/lua/luci/controller/chinadns-ng.lua
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
