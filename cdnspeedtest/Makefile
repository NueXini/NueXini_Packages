# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021-2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=CloudflareSpeedTest
PKG_VERSION:=2.2.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/XIU2/CloudflareSpeedTest/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=4182438be96a9e1611f6f66c5d71e219e2dd98c8dc97d1788e41593048b5c78e

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/XIU2/CloudflareSpeedTest
GO_PKG_LDFLAGS_X:=main.version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/cdnspeedtest
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Getting the fastest ips to your network of CDN
  URL:=https://github.com/XIU2/CloudflareSpeedTest
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=0

define Package/cdnspeedtest/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/CloudflareSpeedTest $(1)/usr/bin/cdnspeedtest

	$(INSTALL_DIR) $(1)/usr/share/CloudflareSpeedTest
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ip.txt $(1)/usr/share/CloudflareSpeedTest/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/ipv6.txt $(1)/usr/share/CloudflareSpeedTest/
endef

$(eval $(call GoBinPackage,cdnspeedtest))
$(eval $(call BuildPackage,cdnspeedtest))
