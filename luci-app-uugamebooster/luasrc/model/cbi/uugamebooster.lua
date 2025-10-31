require("luci.util")

mp = Map("uugamebooster")
mp.title = translate("UU Game Accelerator")
mp.description = translate("A Paid Game Acceleration service")

mp:section(SimpleSection).template  = "uugamebooster/uugamebooster_status"

s = mp:section(TypedSection, "uugamebooster")
s.anonymous = true
s.addremove = false

o = s:option(Flag, "enabled", translate("Enable"))
o.default = 0
o.optional = false

mp:section(SimpleSection).template  = "uugamebooster/uugamebooster_qcode"

return mp
