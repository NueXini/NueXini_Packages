local m, s, o

m = Map("clouddrive2", translate("CloudDrive2"), translate("Configure and manage CloudDrive2"))

m:section(SimpleSection).template="clouddrive2/status"

s = m:section(TypedSection, "clouddrive2", translate("Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Flag, "enabled", translate("Enable"))
o.rmempty = false

o = s:option(Value, "port", translate("Port"))
o.datatype = "port"
o.default = "19798"
-- 
-- o = s:option(Value, "mount_point", translate("Mount Point"))
-- o.default = "/mnt/clouddrive"

return m
