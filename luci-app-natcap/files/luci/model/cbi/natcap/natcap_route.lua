-- Copyright 2019 X-WRT <dev@x-wrt.com>

local nt = require "luci.sys".net

local m = Map("natcapd", luci.xml.pcdata(translate("Route Setup")), translate("select route gateway for each lan"))

m:section(SimpleSection).template  = "natcap/natcap"

local s = m:section(TypedSection, "natcapd", "")
s.addremove = false
s.anonymous = true

--rulesets
local u = m:section(TypedSection, "ruleset", "")
u.addremove = true
u.anonymous = true
u.template = "cbi/tblsection"

e = u:option(Value, "src", translate("From Client(s)"))
e.datatype = "string"
e.rmempty  = false
e.placeholder = "192.168.1.100 or AA:00:11:23:44:55"

e = u:option(Value, "dst", translate("To Destination"))
e.datatype = "string"
e.rmempty  = false
e.placeholder = "ipset name"

e = u:option(ListValue, "target", translate("Target Gateway"))
e:value("", translate("Please select..."))
local ut = require "luci.util"
local sys  = require "luci.sys"
local text = ut.trim(sys.exec("cat /dev/natcap_ctl"))
for ip in text:gmatch("server 0 ([0-9.]+[^\n]+)") do
	e:value(ip)
end

--rules
u = m:section(TypedSection, "rule", "")
u.addremove = true
u.anonymous = true
u.template = "cbi/tblsection"

e = u:option(Value, "src", translate("From Client(s)"))
e.datatype = "string"
e.rmempty  = false
e.placeholder = "192.168.1.100 or AA:00:11:23:44:55"

e = u:option(ListValue, "target", translate("Target Gateway"))
e:value("", translate("Please select..."))
local ut = require "luci.util"
local sys  = require "luci.sys"
local text = ut.trim(sys.exec("cat /dev/natcap_ctl"))
for ip in text:gmatch("server 0 ([0-9.]+[^\n]+)") do
	e:value(ip)
end

return m
