#
# Copyright (C) 2017-2019 Chen Minqiang <ptpt52@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=p910nd-helper
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_SOURCE_VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
PKG_MAINTAINER:=Chen Minqiang <ptpt52@gmail.com>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/p910nd-helper
  CATEGORY:=LuCI
  SUBMENU:=Printer
  DEPENDS:=
  TITLE:=p910nd printer firmware and helper
endef

define Package/p910nd-helper/install
	$(INSTALL_DIR) $(1)/usr/share/p910nd/firmware
	$(INSTALL_DATA) ./firmware/* $(1)/usr/share/p910nd/firmware/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/usb_printerid $(1)/usr/bin/usb_printerid
	$(INSTALL_DIR) $(1)/etc/hotplug.d/usb
	$(INSTALL_BIN) ./25-usb-printer-helper.hotplug $(1)/etc/hotplug.d/usb/25-usb-printer-helper

endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

$(eval $(call BuildPackage,p910nd-helper))
