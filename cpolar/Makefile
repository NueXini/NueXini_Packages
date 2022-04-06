#
# Copyright 2021-2022 Michael Zhang <probezy@gmail.com>
# Licensed to the public under the MIT License.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cpolar
PKG_VERSION:=3.2.86.16
PKG_RELEASE:=$(AUTORELEASE)

PKG_LICENSE:=MIT
PKG_MAINTAINER:=cpolar.com

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=@(aarch64||arm||mipsel||mipsle||x86_64)
	TITLE:=Cpolar Penetration Tool
	URL:=https://www.cpolar.com/
endef

define Package/$(PKG_NAME)/description
It is a safe intranet penetration tool. It can easily publish the internal website to the public website.
endef

ifeq ($(ARCH),x86_64)
	CPOLAR_ARCH:=amd64
	PKG_HASH:=4cb87f092ac5a34d0715d518008b415d9383265e4f0e1fb14cbff69228315eba
endif

ifeq ($(ARCH),mipsel)
	CPOLAR_ARCH:=mips
	PKG_HASH:=6e555f2be2f0d778bacc2056358b51f0e6e1c8bab7451ae83e5797eb11eccab9
endif

ifeq ($(ARCH),mipsle)
	CPOLAR_ARCH:=mipsle
	PKG_HASH:=147464f99401214b99d9bc83fdf79c0d32689fa63624c21cb28e4ab7d205bfed
endif

ifeq ($(ARCH),arm)
	CPOLAR_ARCH:=arm
	PKG_HASH:=1ca60bdc1b0c3bd3d49efaa2f89dc7d6177bf17aba671902943be5f1f58cce10
endif

ifeq ($(ARCH),aarch64)
	CPOLAR_ARCH:=arm64
	PKG_HASH:=3ad4b1c9615ffda079cf699bc037e88543c75e7746ab7c35e273a5a2068e6357
endif

PKG_SOURCE_URL:=https://www.cpolar.com/static/downloads/releases/$(PKG_VERSION)/
PKG_SOURCE:=$(PKG_NAME)-stable-linux-$(CPOLAR_ARCH).tar.gz

define Build/Prepare
	mkdir -p $(PKG_NAME)
	tar -C $(PKG_BUILD_DIR)/ -zxf $(DL_DIR)/$(PKG_SOURCE)
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/cpolar
endef

define Package/$(PKG_NAME)/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cpolar $(1)/usr/bin/cpolar
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
chmod +x $(1)/etc/uci-defaults/40_luci-cpolar
chmod +x $(1)/etc/firewall.cpolar
if [ -z "$${IPKG_INSTROOT}" ] ; then
	( . /etc/uci-defaults/40_luci-cpolar ) && rm -f /etc/uci-defaults/40_luci-cpolar
fi

chmod 755 "$${IPKG_INSTROOT}/etc/init.d/cpolar" >/dev/null 2>&1
ln -sf "../init.d/cpolar" \
	"$${IPKG_INSTROOT}/etc/rc.d/S99cpolar" >/dev/null 2>&1

exit 0
endef

define Package/$(PKG_NAME)/postrm
#!/bin/sh

if [ -s "$${IPKG_INSTROOT}/etc/rc.d/S99cpolar" ] ; then
	rm -f "$${IPKG_INSTROOT}/etc/rc.d/S99cpolar"
fi

if [ -s "$${IPKG_INSTROOT}/etc/init.d/cpolar" ] ; then
	rm -f "$${IPKG_INSTROOT}/etc/init.d/cpolar"
fi

exit 0
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
