-- Copyright 2019 X-WRT <dev@x-wrt.com>

local nt = require "luci.sys".net

local m = Map("natcapd", luci.xml.pcdata(translate("Natcap Service")), translate("Natcap to avoid censorship/filtering/logging"))

m:section(SimpleSection).template  = "natcap/natcap"

local s = m:section(TypedSection, "natcapd", "")
s.addremove = false
s.anonymous = true

s:tab("general", translate("General Settings"))
s:tab("advanced", translate("Advanced Settings"))
s:tab("serverlist", translate("Server List"))
s:tab("macfilter", translate("Mac Filter"))
s:tab("ipfilter", translate("IP Filter"))
s:tab("system", translate("System Settings"))

e = s:taboption("general", Flag, "enabled", translate("Enable Natcap"))
e.default = e.disabled
e.rmempty = false

e = s:taboption("general", Value, "account", translate("Natcap Account"))
e.rmempty = true
e.placeholder = 'account'

e = s:taboption("serverlist", DynamicList, "server", translate("Natcap Servers"), translate("Please fill in the server by format (ip:port)"))
e.datatype = "list(string)"
e.placeholder = "1.2.3.4:0"

e = s:taboption("general", ListValue, "cnipwhitelist_mode", translate("Network traffic strategy"))
e.default = "0"
e:value("0", translate("Smart auto proxy"))
e:value("1", translate("All International traffic proxy"))
e:value("2", translate("Customization proxy"))
e.rmempty = false

e = s:taboption("general", Value, "server_persist_timeout", translate("Server Switching Interval (s)"), translate("How long to switch the server."))
e.default = '30'
e.rmempty = true
e.placeholder = '30'

e = s:taboption("general", Flag, "server_persist_lock", translate("Lock on server"), translate("do not switch servers by automatic detection"))
e.default = e.disabled
e.rmempty = false

e = s:taboption("advanced", Flag, "enable_encryption", translate("Enable Encryption"))
e.default = e.enabled
e.rmempty = false

e = s:taboption("advanced", Flag, "sproxy", translate("TCP Proxy Acceleration"), translate("Recommended to use the server's TCP proxy and Google BBR algorithm to accelerate."))
e.default = e.disabled
e.rmempty = false

e = s:taboption("advanced", Flag, "block_dns6", translate("BLOCK IPv6 DNS"), translate("Block IPv6 DNS to prevent poisoning"))
e.default = e.enabled
e.rmempty = false

e = s:taboption("advanced", Value, "dns_server", translate("DNS Server"), translate("Please fill in the server by format (ip:port)"))
e.datatype = "ip4addrport"
e.placeholder = "8.8.8.8:53"

e = s:taboption("advanced", Flag, "encode_mode", translate("Force TCP encode as UDP"), translate("Do not enable unless the normal mode is not working."))
e.default = e.disabled
e.rmempty = false

e = s:taboption("advanced", Flag, "udp_encode_mode", translate("Force UDP encode as TCP"), translate("Do not enable unless the normal mode is not working."))
e.default = e.disabled
e.rmempty = false

e = s:taboption("advanced", Value, "natcap_redirect_port", translate("Local Server TCP Listening Port"), translate("0 Disabled，Otherwise Enabled"))
e.datatype = "portrange"
e.rmempty = true
e.placeholder = '0'

e = s:taboption("advanced", Value, "natcap_client_redirect_port", translate("Local Client TCP Listening Port"), translate("0 Disabled，Otherwise Enabled"))
e.datatype = "portrange"
e.rmempty = true
e.placeholder = '0'

e = s:taboption("advanced", Flag, "http_confusion", translate("HTTP Obfuscation"), translate("Disguise the traffic into HTTP."))
e.default = e.disabled
e.rmempty = false

e = s:taboption("advanced", Value, "htp_confusion_host", translate("Obfuscation Host"))
e.rmempty = true
e.placeholder = 'bing.com'

e = s:taboption("macfilter", ListValue, "macfilter", translate("Mac Address Filter"))
e:value("", translate("Disabled"))
e:value("allow", translate("whitelist (Allow to use Natcap)"))
e:value("deny", translate("blacklist (Forbid to use Natcap)"))

e = s:taboption("macfilter", DynamicList, "maclist", translate("Mac List"))
e.datatype = "macaddr"
nt.mac_hints(function(mac, name) e:value(mac, "%s (%s)" %{ mac, name }) end)

e = s:taboption("ipfilter", ListValue, "ipfilter", translate("IP Address Filter"))
e:value("", translate("Disabled"))
e:value("allow", translate("whitelist (Allow to use Natcap)"))
e:value("deny", translate("blacklist (Forbid to use Natcap)"))

e = s:taboption("ipfilter", DynamicList, "iplist", translate("IP List"))
e.datatype = "ipaddr"
e.placeholder = '192.168.1.0/24'

e = s:taboption("system", Flag, "access_to_cn", translate("Access to China from abroad"))
e.default = e.disabled
e.rmempty = false

e = s:taboption("system", Flag, "full_proxy", translate("Full Proxy"), translate("All traffic goes to proxy."))
e.default = e.disabled
e.rmempty = false

local speed_validate = function(self, value)
	if not value or value == 0 or value == "0" then
		return value
	end

	local i, j
	local v

	i, j = value:find("Kbps$") or value:find("kbps$")
	if i then
		v = tonumber(value:sub(0, i - 1))
		if not v then
			return nil, translate("Invalid rate limit")
		end
		value = v .. "Kbps"
		return value
	end

	i, j = value:find("Mbps$") or value:find("mbps$")
	if i then
		v = tonumber(value:sub(0, i - 1))
		if not v then
			return nil, translate("Invalid rate limit")
		end
		value = v .. "Mbps"
		return value
	end

	i, j = value:find("Gbps$") or value:find("gbps$")
	if i then
		v = tonumber(value:sub(0, i - 1))
		if not v then
			return nil, translate("Invalid rate limit")
		end
		value = v .. "Gbps"
		return value
	end

	return nil, translate("Invalid rate limit")
end

e = s:taboption("system", Value, "rx_speed_limit", translate("Download rate limit"), translate("Unit: <code>Kbps</code> <code>Mbps</code> <code>Gbps</code> Example: 10Mbps or 0 = no limit"))
e.placeholder = '0Mbps'
e.rmempty = true
e.validate = speed_validate

e = s:taboption("system", Value, "tx_speed_limit", translate("Upload rate limit"), translate("Unit: <code>Kbps</code> <code>Mbps</code> <code>Gbps</code> Example: 10Mbps or 0 = no limit"))
e.placeholder = '0Mbps'
e.rmempty = true
e.validate = speed_validate

e = s:taboption("system", Flag, "peer_sni_ban", translate("Disable Remote Mgr"))
e.default = e.disabled
e.rmempty = false

e = s:taboption("system", Value, "ui", translate("UI"))
e.rmempty = true
e.placeholder = 'none'

return m
