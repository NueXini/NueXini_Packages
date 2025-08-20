# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=uugamebooster
PKG_VERSION:=9.8.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(ARCH).tar.gz
PKG_SOURCE_URL:=https://uurouter.gdl.netease.com/uuplugin/openwrt-$(ARCH)/v$(PKG_VERSION)/uu.tar.gz?
ifeq ($(ARCH),aarch64)
  PKG_HASH:=f4483c13dff4bd72abef05d762d456ca4f1a8f9f064a6a6d8d705290d7bcdf70
else ifeq ($(ARCH),arm)
  PKG_HASH:=2cfb51dd2aafdfb616b776d24978baccd433e34e00eb80610a37f99ab524601b
else ifeq ($(ARCH),mipsel)
  PKG_HASH:=e61b7092741d63486154cac2804dc2926fcd3db681f55f1c9a709c5e0e4e5df8
else ifeq ($(ARCH),x86_64)
  PKG_HASH:=3316043ccc3b2cd6dad087ac735bad867feaac04860d28f3ba71024cac9340e9
endif

PKG_LICENSE:=Proprietary

include $(INCLUDE_DIR)/package.mk

STRIP:=true

TAR_CMD=$(HOST_TAR) -C $(1)/ $(TAR_OPTIONS)

define Package/uugamebooster
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=@(aarch64||arm||mipsel||x86_64) +kmod-tun
  TITLE:=NetEase UU Game Booster
  URL:=https://uu.163.com
endef

define Package/uugamebooster/description
  NetEase's UU Game Booster Accelerates Triple-A Gameplay and Market.
endef

define Build/Compile
endef

define Package/uugamebooster/conffiles
/.uuplugin_uuid
/usr/share/uugamebooster/uu.conf
endef

define Package/uugamebooster/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uuplugin $(1)/usr/bin/uugamebooster
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/xtables-nft-multi $(1)/usr/bin/xtables-nft-multi

	$(INSTALL_DIR) $(1)/usr/share/uugamebooster
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/uu.conf $(1)/usr/share/uugamebooster/uu.conf

	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) $(CURDIR)/files/uugamebooster.config $(1)/etc/config/uugamebooster
	$(INSTALL_BIN) $(CURDIR)/files/uugamebooster.init $(1)/etc/init.d/uugamebooster
endef

$(eval $(call BuildPackage,uugamebooster))
