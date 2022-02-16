#
# <https://github.com/KFERMercer/luci-app-baidupcs-web>
# 
# Copyright (C) 2020 KFERMercer <KFER.Mercer@gmail.com>
# Copyright (C) 2020 [CTCGFW] Project OpenWRT
# 
# THIS IS FREE SOFTWARE, LICENSED UNDER GPLv3.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for BaiduPCS-Go
LUCI_DEPENDS:=+baidupcs-web +wget +openssl-util
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-baidupcs-web
PKG_VERSION:=1.0
PKG_RELEASE:=5

PKG_MAINTAINER:=<https://github.com/KFERMercer/luci-app-baidupcs-web>

include ../../luci.mk

# call BuildPackage - OpenWrt buildroot signature
