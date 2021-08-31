# LuCI Material Theme
# Copyright 2015 Lutty Yang <lutty@wcan.in>
#
# Licensed under the Apache License v2.0
# http://www.apache.org/licenses/LICENSE-2.0

include $(TOPDIR)/rules.mk

THEME_NAME:=material
THEME_TITLE:=Material

PKG_NAME:=luci-theme-$(THEME_NAME)
PKG_VERSION:=0.2.19
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-theme-$(THEME_NAME)
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=9. Themes
  DEPENDS:=+libc
  TITLE:=LuCI Theme - $(THEME_TITLE)
  URL:=http://wcan.in/
  PKGARCH:=all
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-theme-$(THEME_NAME)/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	echo "uci set luci.themes.$(THEME_TITLE)=/luci-static/$(THEME_NAME); uci commit luci" > $(1)/etc/uci-defaults/30-luci-theme-$(THEME_NAME)
	$(INSTALL_DIR) $(1)/www/luci-static/$(THEME_NAME)
	$(CP) -a ./files/htdocs/* $(1)/www/luci-static/$(THEME_NAME)/ 2>/dev/null || true
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/themes/$(THEME_NAME)
	$(CP) -a ./files/templates/* $(1)/usr/lib/lua/luci/view/themes/$(THEME_NAME)/ 2>/dev/null || true
endef

define Package/luci-theme-$(THEME_NAME)/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	( . /etc/uci-defaults/30-luci-theme-$(THEME_NAME) ) && rm -f /etc/uci-defaults/30-luci-theme-$(THEME_NAME)
}
endef

$(eval $(call BuildPackage,luci-theme-$(THEME_NAME)))
