include $(TOPDIR)/rules.mk

PKG_NAME:=libcryptopp
PKG_VERSION:=8.6.0
PKG_RELEASE:=1

PKG_SOURCE:=CRYPTOPP_$(subst .,_,$(PKG_VERSION)).tar.gz
PKG_SOURCE_URL:=https://github.com/weidai11/cryptopp/archive/
PKG_HASH:=9304625f4767a13e0a5f26d0f019d78cf9375604a33e5391c3bf2e81399dfeb8

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_LICENSE:=LGPL-2.1

include $(INCLUDE_DIR)/package.mk

define Package/libcryptopp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libcryptopp
  DEPENDS:=+libpthread 
endef

define Package/libcryptopp/description
  Crypto++ is library for creating C++ programs which use cryptographic algorithms.
  The library uses a Pipes & Filters architecture with heavy use of templates and
  abstract base classes.
endef

TARGET_CFLAGS += $(FPIC)

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) $(PKG_BUILD_DIR)/../cryptopp-CRYPTOPP_$(subst .,_,$(PKG_VERSION))/* $(PKG_BUILD_DIR)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr
	$(CP) $(PKG_INSTALL_DIR)/usr/local/* $(1)/usr/
endef

define Package/libcryptopp/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/*.a $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libcryptopp))