-- Copyright 2019 X-WRT <dev@x-wrt.com>

local nt = require "luci.sys".net

local m = Map("natcapd", luci.xml.pcdata(translate("One Key VPN")))

m:section(SimpleSection).template  = "natcap/natcapd"

local s = m:section(TypedSection, "natcapd", "")
s.addremove = false
s.anonymous = true

s:tab("system", translate("System Settings"))

if nixio.fs.access("/etc/init.d/openvpn") then
	e = s:taboption("system", Flag, "natcapovpn", translate("Enable OpenVPN Server"), translate("Allows you connect to router via VPN, the router need to have a public IP."))
	e.default = e.disabled
	e.rmempty = false
end

e = s:taboption("system", Flag, "pptpd", translate("Enable The PPTP Server"), translate("Allows you connect to router via VPN, the router need to have a public IP."))
e.default = e.disabled
e.rmempty = false

local u = m:section(TypedSection, "pptpuser", "")
u.addremove = true
u.anonymous = true
u.template = "cbi/tblsection"

e = u:option(Value, "username", translate("PPTP Username"))
e.datatype = "string"
e.rmempty  = false

e = u:option(Value, "password", translate("Password"))
e.datatype = "string"
e.rmempty  = false

return m
