#
# Copyright (C) 2008-2019 Jerrykuku
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Argon Theme
LUCI_DEPENDS:=+curl +jsonfilter
PKG_VERSION:=1.8.4
PKG_RELEASE:=20241221

include $(TOPDIR)/feeds/luci/luci.mk


define Package/luci-theme-argon/postinst
#!/bin/sh
sed -i ":a;$!N;s/tmpl.render.*sysauth_template.*return/local scope = { duser = default_user, fuser = user }\nlocal ok, res = luci.util.copcall\(luci.template.render_string, [[<% include\(\"themes\/\" .. theme .. \"\/sysauth\"\) %>]], scope\)\nif ok then\nreturn res\nend\nreturn luci.template.render\(\"sysauth\", scope\)/;ba" /usr/lib/lua/luci/dispatcher.lua
sed -i ":a;$!N;s/t.render.*sysauth_template.*return/local scope = { duser = h, fuser = a }\nlocal ok, res = luci.util.copcall\(luci.template.render_string, [[<% include\(\"themes\/\" .. theme .. \"\/sysauth\"\) %>]], scope\)\nif ok then\nreturn res\nend\nreturn luci.template.render\(\"sysauth\", scope\)/;ba" /usr/lib/lua/luci/dispatcher.lua
[ -f /usr/lib/lua/luci/view/themes/argon/out_header_login.htm ] && mv -f /usr/lib/lua/luci/view/themes/argon/out_header_login.htm /usr/lib/lua/luci/view/header_login.htm
rm -Rf /var/luci-modulecache
rm -Rf /var/luci-indexcache
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature
