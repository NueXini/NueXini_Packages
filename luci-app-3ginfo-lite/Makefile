#
# Copyright 2021-2023 Rafał Wabik - IceG - From eko.one.pl forum
#
# Licensed to the GNU General Public License v3.0.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-3ginfo-lite
LUCI_TITLE:=LuCI JS Support for 3ginfo-lite
MAINTAINER:=Rafał Wabik <4Rafal@gmail.com>
LUCI_DESCRIPTION:=LuCI JS interface for the 3ginfo-lite. The package allows you to view the parameters of the mobile internet connection.
LUCI_DEPENDS:=+sms-tool +comgt
LUCI_PKGARCH:=all
PKG_VERSION:=1.0.48-20230629

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
