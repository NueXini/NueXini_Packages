#
# Copyright 2021-2022 Michael Zhang <probezy@gmail.com>
# Licensed to the public under the MIT License.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cpolar
PKG_VERSION:=3.2.85
PKG_RELEASE:=4

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
	PKG_HASH:=bb1c93cb12a44bef2a66fab51a8a34e6ededf1884eb2404d9dfd806b6ee21a31
endif

ifeq ($(ARCH),mipsel)
	CPOLAR_ARCH:=mips
	PKG_HASH:=24aa5d4e8be05efa3b3f4a016aec9770cb45da1efb1bc8c9c4e127e1fd5e8663
endif

ifeq ($(ARCH),mipsle)
	CPOLAR_ARCH:=mipsle
	PKG_HASH:=23651397d17c4155d6602e6bf805561a433c5e2f5480fa37340d607a81a321f3
endif

ifeq ($(ARCH),arm)
	CPOLAR_ARCH:=arm
	PKG_HASH:=a5728bb8af146375e9c8b8ffbb2f728ba9d244a8625122b2376e045bb4f2f47d
endif

ifeq ($(ARCH),aarch64)
	CPOLAR_ARCH:=arm64
	PKG_HASH:=c743c8928c6dda1b989ed7a045480c8b1d44b3b7aed34d6e2297e247250fadf6
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