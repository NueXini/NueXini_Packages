module("luci.controller.openlist", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/openlist") then
		return
	end

	local page = entry({"admin", "services", "openlist"}, alias("admin", "services", "openlist", "basic"), _("OpenList"))
	page.dependent = true
	page.acl_depends = { "luci-app-openlist" }

	entry({"admin", "services", "openlist", "basic"}, cbi("openlist/basic"), _("Basic Setting"), 1).leaf = true
	entry({"admin", "services", "openlist", "log"}, cbi("openlist/log"), _("Logs"), 2).leaf = true
	entry({"admin", "services", "openlist", "openlist_status"}, call("openlist_status")).leaf = true
	entry({"admin", "services", "openlist", "get_log"}, call("get_log")).leaf = true
	entry({"admin", "services", "openlist", "clear_log"}, call("clear_log")).leaf = true
	entry({"admin", "services", "openlist", "admin_info"}, call("admin_info")).leaf = true
end

function openlist_status()
	local sys  = require "luci.sys"
	local uci  = require "luci.model.uci".cursor()
	local port = tonumber(uci:get_first("openlist", "openlist", "port"))

	local status = {
		running = (sys.call("pidof openlist >/dev/null") == 0),
		port = (port or 5244)
	}

	luci.http.prepare_content("application/json")
	luci.http.write_json(status)
end

function get_log()
	luci.http.write(luci.sys.exec("cat /var/log/openlist.log"))
end

function clear_log()
	luci.sys.call("cat /dev/null > /var/log/openlist.log")
end

function admin_info()
	local random = luci.sys.exec("/usr/bin/openlist --data $(uci -q get openlist.@openlist[0].data_dir) admin random 2>&1")
	local username = string.match(random, "username: (%S+)")
	local password = string.match(random, "password: (%S+)")

	luci.http.prepare_content("application/json")
	luci.http.write_json({username = username, password = password})
end
