#
#-- Copyright (C) 2021 dz <dingzhong110@gmail.com>
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for easymesh
LUCI_DEPENDS:=+kmod-cfg80211 +batctl-default +kmod-batman-adv +wpad-openssl +dawn
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-easymesh
PKG_VERSION:=1.9
PKG_RELEASE:=1

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
