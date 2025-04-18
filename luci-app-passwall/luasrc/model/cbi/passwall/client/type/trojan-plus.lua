local m, s = ...

local api = require "luci.passwall.api"

if not api.is_finded("trojan-plus") then
	return
end

local type_name = "Trojan-Plus"

local option_prefix = "trojan_plus_"

local function _n(name)
	return option_prefix .. name
end

-- [[ Trojan Plus ]]

s.fields["type"]:value(type_name, "Trojan-Plus")

o = s:option(ListValue, _n("trojan_protocol"))
o:depends({ [_n("trojan_hide")] = "1" }) --不存在的依赖，始终隐藏，用于删除 protocol
o.rewrite_option = "protocol"

o = s:option(Value, _n("address"), translate("Address (Support Domain Name)"))

o = s:option(Value, _n("port"), translate("Port"))
o.datatype = "port"

o = s:option(Value, _n("password"), translate("Password"))
o.password = true

o = s:option(ListValue, _n("tcp_fast_open"), "TCP " .. translate("Fast Open"), translate("Need node support required"))
o:value("false")
o:value("true")

o = s:option(Flag, _n("tls"), translate("TLS"))
o.default = 0
o.validate = function(self, value, t)
	if value then
		local type = s.fields["type"] and s.fields["type"]:formvalue(t) or ""
		if value == "0" and type == type_name then
			return nil, translate("Original Trojan only supported 'tls', please choose 'tls'.")
		end
		return value
	end
end

o = s:option(Flag, _n("tls_allowInsecure"), translate("allowInsecure"), translate("Whether unsafe connections are allowed. When checked, Certificate validation will be skipped."))
o.default = "0"
o:depends({ [_n("tls")] = true })

o = s:option(Value, _n("tls_serverName"), translate("Domain"))
o:depends({ [_n("tls")] = true })

o = s:option(Flag, _n("tls_sessionTicket"), translate("Session Ticket"))
o.default = "0"
o:depends({ [_n("tls")] = true })

api.luci_types(arg[1], m, s, type_name, option_prefix)
