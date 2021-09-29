#
# Copyright (C) 2017-2021 Chen Minqiang <ptpt52@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-proxyxwan
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Chen Minqiang <ptpt52@gmail.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-proxyxwan
	CATEGORY:=LuCI
	SUBMENU:=PROXY XWAN Support
	TITLE:=LuCI Support for proxyxwan
	PKGARCH:=all
	DEPENDS:=+lua-ipops +redsocks
endef

define Package/luci-app-proxyxwan/description
	LuCI Support for proxyxwan.
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/files/luci/i18n/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-proxyxwan/conffiles
/etc/config/proxyxwan
endef

define Package/luci-app-proxyxwan/postinst
#!/bin/sh
if [ -z "$$IPKG_INSTROOT" ]; then
  ( . /etc/uci-defaults/40_luci-app-proxyxwan )
  rm -f /etc/uci-defaults/40_luci-app-proxyxwan

  rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi

exit 0
endef

define Package/luci-app-proxyxwan/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/proxyxwan.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./root/etc/config/proxyxwan $(1)/etc/config/proxyxwan
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/proxyxwan $(1)/etc/init.d/proxyxwan
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./root/etc/uci-defaults/40_luci-app-proxyxwan $(1)/etc/uci-defaults/40_luci-app-proxyxwan
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/*.json $(1)/usr/share/rpcd/acl.d/
	$(INSTALL_DIR) $(1)/usr/share/luci/menu.d
	$(INSTALL_DATA) ./root/usr/share/luci/menu.d/*.json $(1)/usr/share/luci/menu.d/
	$(INSTALL_DIR) $(1)/www/luci-static/resources/view/proxyxwan
	$(INSTALL_DATA) ./htdocs/luci-static/resources/view/proxyxwan/proxyxwan.js $(1)/www/luci-static/resources/view/proxyxwan/proxyxwan.js
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/proxyxwan.hotplug $(1)/etc/hotplug.d/iface/21-proxyxwan
endef

$(eval $(call BuildPackage,luci-app-proxyxwan))
