-- Copyright 2019 X-WRT <dev@x-wrt.com>

local nt = require "luci.sys".net

local m = Map("natcapd", luci.xml.pcdata(translate("Natcap Service")))

m:section(SimpleSection).template  = "natcap/natcap"

local s = m:section(TypedSection, "natcapd", "")
s.addremove = false
s.anonymous = true

s:tab("general", translate("General Settings"))

e = s:taboption("general", Flag, "peer_sni_ban", translate("Disable Remote Mgr"))
e.default = e.disabled
e.rmempty = false

e = s:taboption("general", Flag, "enabled", translate("Enable Natcap"), translate("You need an authorization code to enable international network acceleration."))
e.default = e.disabled
e.rmempty = false

e = s:taboption("general", Flag, "encode_mode", translate("Force TCP encode as UDP"), translate("Do not enable unless the normal mode is not working."))
e.default = e.disabled
e.rmempty = false

e = s:taboption("general", Flag, "peer_mode", translate("Peer Mode"), translate("Do not enable unless the normal mode is not working."))
e.default = e.disabled
e.rmempty = false

e = s:taboption("general", ListValue, "cnipwhitelist_mode", translate("Network traffic strategy"))
e.default = "0"
e:value("0", translate("Smart auto proxy"))
e:value("1", translate("All International traffic proxy"))
e:value("2", translate("Customization proxy"))
e.rmempty = false

e = s:taboption("general", Flag, "full_proxy", translate("Full Proxy"), translate("All traffic goes to proxy."))
e.default = e.disabled
e.rmempty = false

e = s:taboption("general", Value, "ui", translate("UI"))
e.rmempty = true
e.placeholder = 'none'

return m
