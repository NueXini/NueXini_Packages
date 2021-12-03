#
# Copyright 2021-2022 Michael Zhang <probezy@gmail.com>
# Licensed to the public under the MIT License.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-cpolar
PKG_VERSION:=1.0.6
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Michael Zhang <probezy@gmail.com>

LUCI_TITLE:=LuCI support for Cpolar
LUCI_DEPENDS:=+jshn +luci-lib-jsonc +lua +libuci-lua +cpolar
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
endef

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh

if [ -z "$${IPKG_INSTROOT}" ] ; then
	status=$(uci get cpolar.main.enabled 2>/dev/null)
	if [ "$status" == "1" ]; then
		/etc/init.d/cpolar reload
		rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
	fi
fi
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature