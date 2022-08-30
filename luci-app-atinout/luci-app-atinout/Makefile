include $(TOPDIR)/rules.mk
	
LUCI_TITLE:=Web UI for atinout
LUCI_DEPENDS:=+atinout +luci-compat
PKG_LICENSE:=GPLv3
PKG_VERSION:=0.0.3
PKG_RELEASE:=2
	
define Package/luci-app-atinout/postrm
	rm -f /tmp/luci-indexcache
endef
	
include $(TOPDIR)/feeds/luci/luci.mk
	
# call BuildPackage - OpenWrt buildroot signature
