#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk
PKG_NAME:=luci-app-ttnode
LUCI_PKGARCH:=all
PKG_VERSION:=0.3
PKG_RELEASE:=20210627

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=Luci for ttnode Automatic collection Script 
	PKGARCH:=all
	DEPENDS:=+luasocket +lua-md5 +lua-cjson +luasec
endef

define Build/Prepare
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/conffiles
	/etc/config/ttnode
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./src/etc/config/ttnode $(1)/etc/config/ttnode
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./src/etc/init.d/* $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./src/etc/uci-defaults/* $(1)/etc/uci-defaults/
	$(INSTALL_DIR) $(1)/usr/share/ttnode
	$(INSTALL_BIN) ./src/usr/share/ttnode/*.lua $(1)/usr/share/ttnode/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./src/usr/share/rpcd/acl.d/* $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DIR) $(1)/www/ttnode
	$(INSTALL_DATA) ./src/www/ttnode/* $(1)/www/ttnode
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./src/luci/controller/* $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/ttnode
	$(INSTALL_DATA) ./src/luci/model/cbi/ttnode/* $(1)/usr/lib/lua/luci/model/cbi/ttnode/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/ttnode
	$(INSTALL_DATA) ./src/luci/view/ttnode/* $(1)/usr/lib/lua/luci/view/ttnode/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
