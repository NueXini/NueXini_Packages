#
# Copyright 2021-2022 Rafał Wabik - IceG - From eko.one.pl forum
# MIT License

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-3ginfo-lite
LUCI_TITLE:=LuCI panel for 3ginfo-lite
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+sms-tool +comgt
PKG_VERSION:=1.0.29-20221018

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-3ginfo-lite/description
	LuCI panel for 3ginfo-lite
	The package allows visualization of the parameters of a 
	mobile Internet connection.
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

# call BuildPackage - OpenWrt buildroot signature
