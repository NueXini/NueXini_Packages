-- Function to add remote DNS values
local function add_remote_dns_values(remote_dns)
  remote_dns:value("tls://8.8.8.8", "8.8.8.8 (Google DNS)")
  remote_dns:value("tls://8.8.4.4", "8.8.4.4 (Google DNS)")
  remote_dns:value("tls://1.1.1.1", "1.1.1.1 (CloudFlare DNS)")
  remote_dns:value("tls://1.0.0.1", "1.0.0.1 (CloudFlare DNS)")
  remote_dns:value("tls://101.101.101.101", "101.101.101.101 (Quad101 DNS)")
  remote_dns:value("tls://9.9.9.11", "9.9.9.11 (Quad9 DNS)")
  remote_dns:value("tls://149.112.112.11", "149.112.112.11 (Quad9 DNS)")
  remote_dns:value("tls://208.67.222.222", "208.67.222.222 (Open DNS)")
  remote_dns:value("tls://208.67.220.220", "208.67.220.220 (Open DNS)")
  remote_dns:value("tls://94.140.14.140", "94.140.14.140 (AdGuard)")
  remote_dns:value("tls://94.140.14.141", "94.140.14.141 (AdGuard)")
end

-- Create the map
local m = Map("mosdns", translate("MosDNS"))
m.description = translate("MosDNS is a 'programmable' DNS forwarder.")

-- Add the status section
local s = m:section(SimpleSection)
s.template = "mosdns/mosdns_status"

-- Add the main section
s = m:section(TypedSection, "mosdns")
s.addremove = false
s.anonymous = true

-- Enable option
local enable = s:option(Flag, "enabled", translate("Enable"))
enable.rmempty = false

-- Config file option
local configfile = s:option(ListValue, "configfile", translate("MosDNS Config File"))
configfile:value("./def_config.yaml", translate("Default Config"))
configfile:value("./cus_config.yaml", translate("Custom Config"))
configfile.default = "./def_config.yaml"

-- Listen port option
local listenport = s:option(Value, "listen_port", translate("Listen port"))
listenport.datatype = "and(port,min(1))"
listenport.default = 5335
listenport:depends("configfile", "./def_config.yaml")

-- Log level option
local loglv = s:option(ListValue, "loglv", translate("Log Level"))
loglv:value("debug", translate("Debug"))
loglv:value("info", translate("Info"))
loglv:value("warn", translate("Warning"))
loglv:value("error", translate("Error"))
loglv.default = "error"
loglv:depends("configfile", "./def_config.yaml")

-- Log file option
local logfile = s:option(Value, "logfile", translate("MosDNS Log File"))
logfile.placeholder = "/tmp/log/mosdns.log"
logfile.default = "/tmp/log/mosdns.log"
logfile:depends("configfile", "./def_config.yaml")

-- Remote DNS options
local remote_dns = s:option(Value, "remote_dns1", translate("Remote DNS"))
remote_dns.default = "tls://1.0.0.1"
remote_dns:depends("configfile", "./def_config.yaml")
add_remote_dns_values(remote_dns)

local remote_dns2 = s:option(Value, "remote_dns2", "ㅤ")
remote_dns2.default = "tls://208.67.220.220"
remote_dns2:depends("configfile", "./def_config.yaml")
add_remote_dns_values(remote_dns2)

-- DNS Redirect option
local redirect = s:option(Flag, "redirect", translate("Enable DNS Redirect"))
redirect:depends("configfile", "./def_config.yaml")
redirect.default = true

-- DNS ADblock option
local adblock = s:option(Flag, "adblock", translate("Enable DNS ADblock"))
adblock.default = false

-- DNS Helper button
local set_config = s:option(Button, "set_config", translate("DNS Helper"))
set_config.inputtitle = translate("Apply")
set_config.inputstyle = "reload"
set_config.description = translate("This will make the necessary adjustments to other plug-in settings.")
set_config.write = function()
  luci.sys.exec("/usr/share/mosdns/conf_dns.sh &> /dev/null &")
end
set_config:depends("configfile", "./def_config.yaml")

-- Revert Settings button
local unset_config = s:option(Button, "unset_config", translate("Revert Settings"))
unset_config.inputtitle = translate("Apply")
unset_config.inputstyle = "reload"
unset_config.description = translate("This will revert the adjustments.")
unset_config.write = function()
  luci.sys.exec("/usr/share/mosdns/conf_dns.sh unset &> /dev/null &")
end

return m
