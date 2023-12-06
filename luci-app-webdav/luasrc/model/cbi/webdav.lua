-- Licensed to the public under the Apache License 2.0.

local fs = require "nixio.fs"

function sync_value_to_file(value, file)
	value = value:gsub("\r\n?", "\n")
	local old_value = nixio.fs.readfile(file)
	if value ~= old_value then
		nixio.fs.writefile(file, value)
	end
	os.execute("/etc/init.d/webdav start >/dev/null")
end

m = Map("webdav")
m.title	= translate("Webdav")
m.description = translate("Simple Webdav")

m:section(SimpleSection).template  = "webdav/webdav_status"

s = m:section(TypedSection, "webdav")
s.addremove = false
s.anonymous = true

view_enable = s:option(Flag, "enabled", translate("Enable"))

view_cfg = s:option(TextValue, "1", nil)
	view_cfg.rmempty = false
	view_cfg.rows = 43

	function view_cfg.cfgvalue()
		return nixio.fs.readfile("/etc/webdav/webdav.yaml") or ""
	end

	function view_cfg.write(self, section, value)
		sync_value_to_file(value, "/etc/webdav/webdav.yaml")
	end

return m
