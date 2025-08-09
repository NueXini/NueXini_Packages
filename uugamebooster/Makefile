# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=uugamebooster
PKG_VERSION:=9.6.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(ARCH).tar.gz
PKG_SOURCE_URL:=http://uurouter.gdl.netease.com/uuplugin/openwrt-$(ARCH)/v$(PKG_VERSION)/uu.tar.gz?
ifeq ($(ARCH),aarch64)
  PKG_HASH:=6e7281eb6d1998946e9b25070c8f5cd6dffc2b821a9e4bfbe27d37ff6507f869
else ifeq ($(ARCH),arm)
  PKG_HASH:=eb1e61022d8d7fd7d684e13cb76ffdce36503d08872fe69cb54aff620593a91b
else ifeq ($(ARCH),mipsel)
  PKG_HASH:=3c89c23cb1afdc24b41684dcd62fdd4d01c39cb8c313d0827a6c4a89995d047b
else ifeq ($(ARCH),x86_64)
  PKG_HASH:=63598cba6f05f159b5e4379dd0c323f48a5e559335309f876b9868c123daf0f7
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
	$(INSTALL_CONF) ./files/uugamebooster.config $(1)/etc/config/uugamebooster
	$(INSTALL_BIN) ./files/uugamebooster.init $(1)/etc/init.d/uugamebooster
endef

$(eval $(call BuildPackage,uugamebooster))
