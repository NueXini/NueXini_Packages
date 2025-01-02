local api = require "luci.passwall.api"
local appname = "passwall"
local has_singbox = api.finded_com("singbox")
local has_xray = api.finded_com("xray")

m = Map(appname)

local nodes_table = {}
for k, e in ipairs(api.get_valid_nodes()) do
	nodes_table[#nodes_table + 1] = e
end

s = m:section(NamedSection, arg[1], translate("Socks Config"), translate("Socks Config"))
s.addremove = false
s.dynamic = false

---- Enable
o = s:option(Flag, "enabled", translate("Enable"))
o.default = 1
o.rmempty = false

local auto_switch_tip
local current_node = api.get_cache_var("socks_" .. arg[1])
if current_node then
	local n = m:get(current_node)
	if n then
		if tonumber(m:get(arg[1], "enable_autoswitch") or 0) == 1 then
			if n then
				local remarks = api.get_node_remarks(n)
				local url = api.url("node_config", n[".name"])
				auto_switch_tip = translatef("Current node: %s", string.format('<a href="%s">%s</a>', url, remarks)) .. "<br />"
			end
		end
	end
end

socks_node = s:option(ListValue, "node", translate("Node"))
if auto_switch_tip then
	socks_node.description = auto_switch_tip
end

o = s:option(Flag, "bind_local", translate("Bind Local"), translate("When selected, it can only be accessed localhost."))
o.default = "0"

local n = 1
m.uci:foreach(appname, "socks", function(s)
	if s[".name"] == section then
		return false
	end
	n = n + 1
end)

o = s:option(Value, "port", "Socks " .. translate("Listen Port"))
o.default = n + 1080
o.datatype = "port"
o.rmempty = false

if has_singbox or has_xray then
	o = s:option(Value, "http_port", "HTTP " .. translate("Listen Port") .. " " .. translate("0 is not use"))
	o.default = 0
	o.datatype = "port"
end

o = s:option(Flag, "log", translate("Enable") .. " " .. translate("Log"))
o.default = 1
o.rmempty = false

o = s:option(Flag, "enable_autoswitch", translate("Auto Switch"))
o.default = 0
o.rmempty = false

o = s:option(Value, "autoswitch_testing_time", translate("How often to test"), translate("Units:seconds"))
o.datatype = "min(10)"
o.default = 30
o:depends("enable_autoswitch", true)

o = s:option(Value, "autoswitch_connect_timeout", translate("Timeout seconds"), translate("Units:seconds"))
o.datatype = "min(1)"
o.default = 3
o:depends("enable_autoswitch", true)

o = s:option(Value, "autoswitch_retry_num", translate("Timeout retry num"))
o.datatype = "min(1)"
o.default = 1
o:depends("enable_autoswitch", true)
	
autoswitch_backup_node = s:option(DynamicList, "autoswitch_backup_node", translate("List of backup nodes"))
autoswitch_backup_node:depends("enable_autoswitch", true)
function o.write(self, section, value)
	local t = {}
	local t2 = {}
	if type(value) == "table" then
		local x
		for _, x in ipairs(value) do
			if x and #x > 0 then
				if not t2[x] then
					t2[x] = x
					t[#t+1] = x
				end
			end
		end
	else
		t = { value }
	end
	return DynamicList.write(self, section, t)
end

o = s:option(Flag, "autoswitch_restore_switch", translate("Restore Switch"), translate("When detects main node is available, switch back to the main node."))
o:depends("enable_autoswitch", true)

o = s:option(Value, "autoswitch_probe_url", translate("Probe URL"), translate("The URL used to detect the connection status."))
o.default = "https://www.google.com/generate_204"
o:value("https://cp.cloudflare.com/", "Cloudflare")
o:value("https://www.gstatic.com/generate_204", "Gstatic")
o:value("https://www.google.com/generate_204", "Google")
o:value("https://www.youtube.com/generate_204", "YouTube")
o:value("https://connect.rom.miui.com/generate_204", "MIUI (CN)")
o:value("https://connectivitycheck.platform.hicloud.com/generate_204", "HiCloud (CN)")
o:depends("enable_autoswitch", true)

for k, v in pairs(nodes_table) do
	autoswitch_backup_node:value(v.id, v["remark"])
	socks_node:value(v.id, v["remark"])
end

o = s:option(DummyValue, "btn", " ")
o.template = appname .. "/socks_auto_switch/btn"
o:depends("enable_autoswitch", true)

return m
