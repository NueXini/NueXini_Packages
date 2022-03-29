# Copyright 2021-2022 Rafał Wabik - IceG - From eko.one.pl forum
# MIT License

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-3ginfo-lite
LUCI_TITLE:=LuCI panel for 3ginfo-lite
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+sms-tool
PKG_VERSION:=1.0.15-20220325
PKG_RELEASE:=1

define Package/$(PKG_NAME)
	$(call Package/luci/webtemplate)
	TITLE:=$(LUCI_TITLE)
	DEPENDS:=$(LUCI_DEPENDS)
endef

define Package/$(PKG_NAME)/description
	LuCI panel for 3ginfo-lite.
endef

define Package/luci-app-3ginfo-lite/postinst
#!/bin/sh
chmod +x /usr/share/3ginfo-lite/3ginfo.sh
chmod +x /usr/share/3ginfo-lite/set_3ginfo_port.sh
chmod +x /usr/share/3ginfo-lite/3ginfo-hilink/alcatel_hilink.sh
chmod +x /usr/share/3ginfo-lite/3ginfo-hilink/huawei_hilink.sh
chmod +x /usr/share/3ginfo-lite/3ginfo-hilink/zte.sh
rm -rf /tmp/luci-indexcache
rm -rf /tmp/luci-modulecache/
/usr/share/3ginfo-lite/set_3ginfo_port.sh
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

$(eval $(call BuildPackage,$(PKG_NAME)))

# call BuildPackage - OpenWrt buildroot signature
