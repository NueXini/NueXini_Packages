require("luci.util")

m = Map("openlist", translate("OpenList"),
	translate("A file list/WebDAV program that supports multiple storages, powered by Gin and Solidjs.") .. "<br />" ..
	translate("Default webUI/WebDAV login username is %s and password is %s."):format('<code>admin</code>', '<code>password</code>'))

m:section(SimpleSection).template = "openlist/openlist_status"

s = m:section(TypedSection, "openlist")
s.anonymous = true
s.addremove = false

o = s:option(Flag, "enabled", translate("Enable"))
o.default = 0

o = s:option(Value, "listen_addr", translate("Listen address"))
o.datatype = "ipaddr"
o.placeholder = '0.0.0.0'

o = s:option(Value, "listen_http_port", translate("Listen port"))
o.datatype = "port"
o.placeholder = 5244

o = s:option(Value, "site_login_expire", translate("Login expiration time"), translate("User login expiration time (in hours)."))
o.datatype = "uinteger"
o.placeholder = 48

o = s:option(Value, "site_max_connections", translate("Max connections"), translate("The maximum number of concurrent connections at the same time (0 = unlimited)."))
o.datatype = "uinteger"
o.placeholder = 0

o = s:option(Flag, "site_tls_insecure", translate("Allow insecure connection"), translate("Allow connection even if the remote TLS certificate is invalid (<strong>not recommended</strong>)."))

o = s:option(Flag, "log_enable", translate("Enable logging"))
o.default = 1

o = s:option(Value, "log_max_size", translate("Max log size"), translate("The maximum size in megabytes of the log file before it gets rotated."))
o.datatype = "uinteger"
o.placeholder = 5
o:depends("log_enable", "1")

o = s:option(Value, "log_max_backups", translate("Max log backups"), translate("The maximum number of old log files to retain."))
o.datatype = "uinteger"
o.placeholder = 1
o:depends("log_enable", "1")

o = s:option(Value, "log_max_age", translate("Max log age"), translate("The maximum days of the log file to retain."))
o.datatype = "uinteger"
o.placeholder = 15
o:depends("log_enable", "1")

return m
