# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=libcron
PKG_VERSION:=1.3.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/PerMalmberg/libcron.git
PKG_SOURCE_DATE:=2020-12-04
PKG_SOURCE_VERSION:=b0046755bda166dde253e33f68a5b0a1c3ed387e
PKG_MIRROR_HASH:=04ed111a5b15b713fc51ca728f5c2cbe386a5bff642a3b3e1b928b695f6cec2f

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libcron
  SECTION:=lib
  CATEGORY:=Libraries
  URL:=https://github.com/PerMalmberg/libcron
  TITLE:=A C++ scheduling library using cron formatting
endef

define Package/libcron/description
  Libcron offers an easy to use API to add callbacks with corresponding cron-formatted strings.
endef

define Build/Install
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libcron/out/Release/liblibcron.a $(PKG_INSTALL_DIR)/usr/lib/
	$(INSTALL_DIR) $(PKG_INSTALL_DIR)/usr/include/libcron/
	$(CP) $(PKG_BUILD_DIR)/libcron/include/* $(PKG_INSTALL_DIR)/usr/include/
	$(CP) $(PKG_BUILD_DIR)/libcron/externals/date/include/* $(PKG_INSTALL_DIR)/usr/include/
endef

$(eval $(call BuildPackage,libcron))
