#
# Copyright (C) 2017-2019 Chen Minqiang <ptpt52@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=natcap
PKG_VERSION:=8.0.1
PKG_RELEASE:=20210910

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE).tar.xz
PKG_SOURCE_URL:=https://github.com/ptpt52/natcap.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_RELEASE)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MIRROR_HASH:=1f7672a00f43e1937a5559221cd1194926481bcede275679702c16f6c62f76a5
PKG_MAINTAINER:=Chen Minqiang <ptpt52@gmail.com>
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/natcapd-client
  CATEGORY:=LuCI
  SUBMENU:=Natcap Support
  DEPENDS:= +libev +libc
  TITLE:=Natcapd_client agent for natcap
endef

define Package/natcapd-server
  CATEGORY:=LuCI
  SUBMENU:=Natcap Support
  DEPENDS:= +libev +libc
  TITLE:=Natcapd_server agent for natcap
endef

define Package/natcapd-client/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/natcapd/natcapd-client $(1)/usr/sbin/natcapd-client
endef

define Package/natcapd-server/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/natcapd/natcapd-server $(1)/usr/sbin/natcapd-server
endef

define Package/natcapd-peer
  CATEGORY:=LuCI
  SUBMENU:=Natcap Support
  TITLE:=natcapd peer for natcap
  DEPENDS:= +kmod-natcap \
			+lua-cjson \
			+ipset \
			+busybox +@BUSYBOX_CUSTOM \
			+@BUSYBOX_CONFIG_TIMEOUT
endef

define Package/natcapd-peer/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/natcapd-peer.init $(1)/etc/init.d/natcapd-peer
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/natcapd-peer.sh $(1)/usr/sbin/natcapd-peer
endef

define Package/natcapd/Default
  CATEGORY:=LuCI
  SUBMENU:=Natcap Support
  DEPENDS:= +kmod-natcap
endef

define Package/natcapd
  $(call Package/natcapd/Default)
  TITLE:=natcapd agent for natcap
  DEPENDS += +libustream-ssl +uclient-fetch \
			 +lua-cjson \
			 +ipset \
			 +dnsmasq-full +@PACKAGE_dnsmasq_full_ipset \
			 +busybox +@BUSYBOX_CUSTOM \
			 +@BUSYBOX_CONFIG_CKSUM \
			 +@BUSYBOX_CONFIG_BASE64 \
			 +@BUSYBOX_CONFIG_TIMEOUT \
			 +@BUSYBOX_CONFIG_NOHUP \
			 +@BUSYBOX_CONFIG_DIFF
endef

define Package/natcapd/description
 Natcapd agent for natcap
endef

define Package/natcapd-mini/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/natcapd_boot.init $(1)/etc/init.d/natcapd_boot
	$(INSTALL_BIN) ./files/natcapd.init $(1)/etc/init.d/natcapd
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/natcapd.config $(1)/etc/config/natcapd
	$(INSTALL_DIR) $(1)/usr/share/natcapd
	$(INSTALL_DATA) ./files/firewall.include $(1)/usr/share/natcapd/firewall.include
	$(INSTALL_DATA) ./files/accelerated-domains.gfwlist.dnsmasq.conf $(1)/usr/share/natcapd/accelerated-domains.gfwlist.dnsmasq.conf
	$(INSTALL_DATA) ./files/gfwlist_update.sh $(1)/usr/share/natcapd/gfwlist_update.sh
	$(INSTALL_DATA) ./files/cnlist_update.sh $(1)/usr/share/natcapd/cnlist_update.sh
	$(INSTALL_DATA) ./files/board_mac.lua $(1)/usr/share/natcapd/board_mac.lua
	$(INSTALL_DATA) ./files/yy.json.lua $(1)/usr/share/natcapd/yy.json.lua
	$(INSTALL_DATA) ./files/yy.sn.json.lua $(1)/usr/share/natcapd/yy.sn.json.lua
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/cniplist.set $(1)/usr/share/natcapd/cniplist.set
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/C_cniplist.set $(1)/usr/share/natcapd/C_cniplist.set
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/cniplist.orig.set $(1)/usr/share/natcapd/cniplist.orig.set
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/hkiplist.orig.set $(1)/usr/share/natcapd/hkiplist.orig.set
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/local.set $(1)/usr/share/natcapd/local.set
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/getflix.set $(1)/usr/share/natcapd/getflix.set
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/gfwlist1.tocn.ip.txt $(1)/usr/share/natcapd/gfwlist1.tocn.ip.txt
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/gfwlist1.tocn.host.txt $(1)/usr/share/natcapd/gfwlist1.tocn.host.txt
	$(INSTALL_DATA) ./files/natcapd.config.dubai $(1)/usr/share/natcapd/natcapd.config.dubai
	$(INSTALL_DATA) ./files/cacert.pem $(1)/usr/share/natcapd/cacert.pem
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/natcapd.sh $(1)/usr/sbin/natcapd
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DATA) ./files/natcapd.defaults $(1)/etc/uci-defaults/95-natcapd
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/20-natcapd.hotplug $(1)/etc/hotplug.d/iface/20-natcapd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/peer_ctl.sh $(1)/usr/sbin/peer_ctl
endef

define Package/natcapd/conffiles
/etc/config/natcapd
endef

define Package/natcapd/postinst
#!/bin/sh

if [ -z "$$IPKG_INSTROOT" ]; then
  ( . /etc/uci-defaults/95-natcapd )
  rm -f /etc/uci-defaults/95-natcapd
fi

exit 0
endef

define Package/natcapd/install
	$(Package/natcapd-mini/install)
	$(INSTALL_DIR) $(1)/usr/share/natcapd
	$(INSTALL_DATA) ./files/natcapd.pptpd.sh $(1)/usr/share/natcapd/natcapd.pptpd.sh
	$(INSTALL_DATA) ./files/natcapd.openvpn.sh $(1)/usr/share/natcapd/natcapd.openvpn.sh
	$(INSTALL_DATA) ./files/natcapd.cone_nat_unused.sh $(1)/usr/share/natcapd/natcapd.cone_nat_unused.sh
	$(INSTALL_DIR) $(1)/usr/share/natcapd/openvpn
	$(INSTALL_DATA) ./files/openvpn/client.conf $(1)/usr/share/natcapd/openvpn/client.conf
	$(INSTALL_DATA) ./files/openvpn/client.key $(1)/usr/share/natcapd/openvpn/client.key
	$(INSTALL_DATA) ./files/openvpn/client.crt $(1)/usr/share/natcapd/openvpn/client.crt
	$(INSTALL_DATA) ./files/openvpn/dh2048.pem $(1)/usr/share/natcapd/openvpn/dh2048.pem
	$(INSTALL_DATA) ./files/openvpn/ca.crt $(1)/usr/share/natcapd/openvpn/ca.crt
	$(INSTALL_DATA) ./files/openvpn/server.crt $(1)/usr/share/natcapd/openvpn/server.crt
	$(INSTALL_DATA) ./files/openvpn/server.key $(1)/usr/share/natcapd/openvpn/server.key
	$(INSTALL_DATA) ./files/openvpn/ta.key $(1)/usr/share/natcapd/openvpn/ta.key
endef

define KernelPackage/natcap
  CATEGORY:=LuCI
  SUBMENU:=Natcap Support
  TITLE:=Natcap kernel driver
  FILES:=$(PKG_BUILD_DIR)/natcap.ko
  KCONFIG:=
  AUTOLOAD:=$(call AutoLoad,96,natcap)
  DEPENDS:= +kmod-ipt-conntrack +kmod-ipt-nat +kmod-ipt-ipset
endef

define KernelPackage/natcap/description
  Driver for natcap packet proxy to avoid inspection
endef

include $(INCLUDE_DIR)/kernel-defaults.mk

define Build/Compile/natcap
	+$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		$(KERNEL_MAKE_FLAGS) \
		M="$(PKG_BUILD_DIR)" \
		modules
endef

define Build/Compile/natcapd-client
	+$(MAKE_VARS) $(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/natcapd natcapd-client $(MAKE_FLAGS)
endef

define Build/Compile/natcapd-server
	+$(MAKE_VARS) $(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/natcapd natcapd-server $(MAKE_FLAGS)
endef

define Build/Compile
	$(call Build/Compile/natcap)
ifneq ($(CONFIG_PACKAGE_natcapd-client),)
	$(call Build/Compile/natcapd-client)
endif
ifneq ($(CONFIG_PACKAGE_natcapd-server),)
	$(call Build/Compile/natcapd-server)
endif
endef

$(eval $(call KernelPackage,natcap))
$(eval $(call BuildPackage,natcapd))
$(eval $(call BuildPackage,natcapd-client))
$(eval $(call BuildPackage,natcapd-server))
$(eval $(call BuildPackage,natcapd-peer))
