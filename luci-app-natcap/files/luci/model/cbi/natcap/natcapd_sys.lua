-- Copyright 2019 X-WRT <dev@x-wrt.com>

local nt = require "luci.sys".net

local m = Map("natcapd", luci.xml.pcdata(translate("Advanced Options")))

local s = m:section(TypedSection, "natcapd", "")
s.addremove = false
s.anonymous = true

s:tab("system", translate("System Settings"))

e = s:taboption("system", Flag, "full_cone_nat", translate("Full Cone Nat"), translate("Generally do not need to be enabled unless used to play games."))
e.default = e.disabled
e.rmempty = false

e = s:taboption("system", Flag, "enable_natflow", translate("Enable Fast Forwarding"))
e.default = e.disabled
e.rmempty = false

e = s:taboption("system", Flag, "enable_natflow_hw", translate("Enable Fast Forwarding Hardware Offload"))
e.default = e.disabled
e.rmempty = false
e:depends("enable_natflow","1")

return m
