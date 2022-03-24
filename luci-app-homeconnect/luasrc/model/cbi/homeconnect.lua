local s = require "luci.sys"
local m, s, o
m = Map("homeconnect", translate("Home Connect"))
m.description = translate(
                    "HomeConnect is a simple and easy-to-use VPN Server(based on softethervpn5) customized for HomeLede firmware. HomeConnect provides L2TP over IPSec service, 0 configuration, out of the box. You can use the built-in VPN client for ios, android, mac, and windows to connect directly.")
m.template = "homeconnect/index"
s = m:section(TypedSection, "softether")
s.anonymous = true
o = s:option(DummyValue, "softethervpn_status", translate("Current Condition"))
o.template = "homeconnect/status"
o.value = translate("Collecting data...")
o = s:option(Flag, "enable", translate("Enabled"))
o.rmempty = false
--[[
o = s:option(DummyValue, "moreinfo", translate(
                 "<strong>控制台下载：<a onclick=\"window.open('https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.30-9696-beta/softether-vpnserver_vpnbridge-v4.30-9696-beta-2019.07.08-windows-x86_x64-intel.exe')\"><br/>Windows-x86_x64-intel.exe</a><a  onclick=\"window.open('https://www.softether-download.com/files/softether/v4.21-9613-beta-2016.04.24-tree/Mac_OS_X/Admin_Tools/VPN_Server_Manager_Package/softether-vpnserver_manager-v4.21-9613-beta-2016.04.24-macos-x86-32bit.pkg')\"><br/>macos-x86-32bit.pkg</a></strong>"))
 ]] 
m:append(Template("homeconnect/settings"))
return m
