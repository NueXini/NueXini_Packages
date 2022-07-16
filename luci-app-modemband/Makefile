# Copyright 2022 Rafał Wabik - IceG - From eko.one.pl forum
# MIT License

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-modemband
LUCI_TITLE:=LuCI panel for modemband
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+sms-tool +modemband
PKG_VERSION:=1.0.14-20220716
PKG_RELEASE:=1

define Package/$(PKG_NAME)
	$(call Package/luci/webtemplate)
	TITLE:=$(LUCI_TITLE)
	DEPENDS:=$(LUCI_DEPENDS)
endef

define Package/$(PKG_NAME)/description
	LuCI panel for modemband.
endef

define Package/luci-app-modemband/postinst
#!/bin/sh
chmod +x /usr/bin/modemband.sh
rm -rf /tmp/luci-indexcache
rm -rf /tmp/luci-modulecache/
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

# call BuildPackage - OpenWrt buildroot signature
