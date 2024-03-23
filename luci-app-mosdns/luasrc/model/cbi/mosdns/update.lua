local m = Map("mosdns")

local s = m:section(TypedSection, "mosdns", translate("Geodata Update"))
s.addremove = false
s.anonymous = true

local enable_auto_update = s:option(Flag, "geo_auto_update", translate("Enable Auto Database Update"))
enable_auto_update.rmempty = false

local enable_config_update = s:option(Flag, "syncconfig", translate("Enable Config Update"))
enable_config_update.rmempty = false

local update_cycle = s:option(ListValue, "geo_update_week_time", translate("Update Cycle"))
update_cycle:value("*", translate("Every Day"))
update_cycle:value("1", translate("Every Monday"))
update_cycle:value("2", translate("Every Tuesday"))
update_cycle:value("3", translate("Every Wednesday"))
update_cycle:value("4", translate("Every Thursday"))
update_cycle:value("5", translate("Every Friday"))
update_cycle:value("6", translate("Every Saturday"))
update_cycle:value("7", translate("Every Sunday"))
update_cycle.default = "*"

local update_time = s:option(ListValue, "geo_update_day_time", translate("Update Time (Every Day)"))
for t = 0, 23 do
  update_time:value(tostring(t), t .. ":00")
end
update_time.default = "0"

local proxy_url = s:option(Value, "proxy_url", translate("Proxy URL"))
proxy_url.default = ""
proxy_url.rmempty = true

local data_update = s:option(Button, "geo_update_database", translate("Database Update"))
data_update.inputtitle = translate("Check And Update")
data_update.inputstyle = "reload"
data_update.write = function()
  luci.sys.exec("/usr/share/mosdns/mosdns.sh update_mosdns > /dev/null 2>&1 &")
end

return m
