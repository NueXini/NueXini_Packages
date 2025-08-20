# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-openlist2
PKG_VERSION:=1.0.2
PKG_RELEASE:=1

LUCI_TITLE:=LuCI support for openlist
LUCI_DEPENDS:=+openlist +luci-compat

define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	( . /etc/uci-defaults/50-luci-openlist ) && rm -f /etc/uci-defaults/50-luci-openlist
	exit 0
}
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
