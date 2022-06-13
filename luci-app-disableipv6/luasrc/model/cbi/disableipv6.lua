local o=require"luci.dispatcher"
local e=require("luci.model.ipkg")
local s=require"nixio.fs"
local e=luci.model.uci.cursor()
local m,s,e

m=Map("disableipv6",translate("Disable IPV6"),translate("It can disable ipv6 for all eth."))

s=m:section(TypedSection, "onoff","")
s.addremove=false
s.anonymous=true

e=s:option(Flag,"enable",translate("Enable"))
e.rmempty = false
e.default=0

return m
