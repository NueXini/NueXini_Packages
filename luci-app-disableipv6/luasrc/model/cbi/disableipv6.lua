
m = Map("disableipv6", translate("Disable IPV6"), translate("It can disable ipv6 for all eth."))

s = m:section(TypedSection, "onoff")
s.anonymous = true

o = s:option(Flag, "enable", translate("Enable"))
o.rmempty = false
o.default = "0"

return m
