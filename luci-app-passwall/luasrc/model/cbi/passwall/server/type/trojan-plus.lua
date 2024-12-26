local m, s = ...

local api = require "luci.passwall.api"

if not api.is_finded("trojan-plus") then
	return
end

local fs = api.fs

local type_name = "Trojan-Plus"

local option_prefix = "trojan_plus_"

local function _n(name)
	return option_prefix .. name
end

-- [[ Trojan-Plus ]]

s.fields["type"]:value(type_name, "Trojan-Plus")

o = s:option(Value, _n("port"), translate("Listen Port"))
o.datatype = "port"

o = s:option(DynamicList, _n("uuid"), translate("ID") .. "/" .. translate("Password"))
for i = 1, 3 do
	o:value(api.gen_uuid(1))
end

o = s:option(Flag, _n("tls"), translate("TLS"))
o.default = 0
o.validate = function(self, value, t)
	if value then
		local type = s.fields["type"] and s.fields["type"]:formvalue(t) or ""
		if value == "0" and type == type_name then
			return nil, translate("Original Trojan only supported 'tls', please choose 'tls'.")
		end
		if value == "1" then
			local ca = s.fields[_n("tls_certificateFile")] and s.fields[_n("tls_certificateFile")]:formvalue(t) or ""
			local key = s.fields[_n("tls_keyFile")] and s.fields[_n("tls_keyFile")]:formvalue(t) or ""
			if ca == "" or key == "" then
				return nil, translate("Public key and Private key path can not be empty!")
			end
		end
		return value
	end
end

o = s:option(FileUpload, _n("tls_certificateFile"), translate("Public key absolute path"), translate("as:") .. "/etc/ssl/fullchain.pem")
o.default = m:get(s.section, "tls_certificateFile") or "/etc/config/ssl/" .. arg[1] .. ".pem"
o:depends({ [_n("tls")] = true })
o.validate = function(self, value, t)
	if value and value ~= "" then
		if not fs.access(value) then
			return nil, translate("Can't find this file!")
		else
			return value
		end
	end
	return nil
end

o = s:option(FileUpload, _n("tls_keyFile"), translate("Private key absolute path"), translate("as:") .. "/etc/ssl/private.key")
o.default = m:get(s.section, "tls_keyFile") or "/etc/config/ssl/" .. arg[1] .. ".key"
o:depends({ [_n("tls")] = true })
o.validate = function(self, value, t)
	if value and value ~= "" then
		if not fs.access(value) then
			return nil, translate("Can't find this file!")
		else
			return value
		end
	end
	return nil
end

o = s:option(Flag, _n("tls_sessionTicket"), translate("Session Ticket"))
o.default = "0"
o:depends({ [_n("tls")] = true })

o = s:option(Flag, _n("tcp_fast_open"), translate("TCP Fast Open"))
o.default = "0"

o = s:option(Flag, _n("remote_enable"), translate("Enable Remote"), translate("You can forward to Nginx/Caddy/V2ray/Xray WebSocket and more."))
o.default = "1"
o.rmempty = false

o = s:option(Value, _n("remote_address"), translate("Remote Address"))
o.default = "127.0.0.1"
o:depends({ [_n("remote_enable")] = true })

o = s:option(Value, _n("remote_port"), translate("Remote Port"))
o.datatype = "port"
o.default = "80"
o:depends({ [_n("remote_enable")] = true })

o = s:option(Flag, _n("log"), translate("Log"))
o.default = "1"

o = s:option(ListValue, _n("loglevel"), translate("Log Level"))
o.default = "2"
o:value("0", "all")
o:value("1", "info")
o:value("2", "warn")
o:value("3", "error")
o:value("4", "fatal")
o:depends({ [_n("log")] = true })

api.luci_types(arg[1], m, s, type_name, option_prefix)
