include $(TOPDIR)/rules.mk

LUCI_TITLE:=Web UI for smstools3
LUCI_DEPENDS:=+smstools3 +iconv +luci-compat
PKG_LICENSE:=GPLv3
PKG_VERSION:=0.0.6-7

define Package/luci-app-smstools3/postrm
	rm -f /tmp/luci-indexcache
endef

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-smstools3/conffiles
	/etc/config/smstools3
endef

define Package/luci-app-smstools3/prerm
	mv /usr/share/luci-app-smstools3/smstools3.init.orig /etc/init.d/smstools3
endef

# call BuildPackage - OpenWrt buildroot signature
