-- Copyright 2021-2022 Michael Zhang <probezy@gmail.com>
-- Licensed to the public under the MIT License.

local http = require "luci.http"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local fs = require "nixio.fs"
-- local cpolar = require "luci.model.cpolar"
local i18n = require "luci.i18n"
local util = require "luci.util"



module("luci.controller.cpolar.cpolar", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/cpolar") then
		return
	end


	entry({"admin", "services", "cpolar"},
		firstchild(), _("Cpolar")).dependent = false

	entry({"admin", "services", "cpolar", "general"},
		cbi("cpolar/general"), _("General Settings"), 1).leaf = true

	entry({"admin", "services", "cpolar", "tunnels"},
		arcombine(cbi("cpolar/tunnel-list"), cbi("cpolar/tunnel-detail")),
		_("Tunnel"), 2).leaf = true

		entry({"admin", "services", "cpolar", "log"}, form("cpolar/log"),_("Log"), 30).leaf = true

		entry({"admin", "services", "cpolar", "status"}, call("action_status")).leaf = true

		entry({"admin", "services", "cpolar", "version"}, call("action_version")).leaf = true
		
		entry({"admin", "services", "cpolar", "logtail"}, call("action_logtail")).leaf = true
	end


	function action_status()
		local running = false
		local info 
		local message
	
		local pid = util.trim(fs.readfile("/var/run/cpolar.pid") or "")
	
		if pid ~= "" then
			local file = uci:get("cpolar", "@general[0]", "cpolar_file") or ""
			if file ~= "" then
				local file_name = fs.basename(file)
				running = sys.call("pidof %s 2>/dev/null | grep -q %s" % { file_name, pid }) == 0
			end
		end


		info = {
			running = running,
			message = message
		}
		http.prepare_content("application/json")
		http.write_json(info)
	end
	
	function action_version()

		local file = uci:get("cpolar", "@general[0]", "cpolar_file") or ""
	
		local info
	
		if file == "" then
			info = {
				valid = false,
				message = i18n.translate("Invalid Cpolar file")
			}
		else
			if not fs.access(file, "rwx", "rx", "rx") then
				fs.chmod(file, 755)
			end
	
			local version = util.trim(sys.exec("%s version 2>/dev/null | head -n1" % file))
	
			if version ~= "" then
				info = {
					valid = true,
					version = version
				}
			else
				info = {
					valid = false,
					message = i18n.translate("Can't get Cpolar version")
				}
			end
		end
	
		http.prepare_content("application/json")
		http.write_json(info)
	end
	
	function action_logtail()
		local fs = require "nixio.fs"
		local log_path = "/var/log/cpolar-access.log"
		local e = {}
		e.running = luci.sys.call("pidof cpolar >/dev/null") == 0
		if fs.access(log_path) then
			e.log = luci.sys.exec("tail -n 100 %s | sed 's/\\x1b\\[[0-9;]*m//g'" % log_path)
		else
			e.log = ""
		end
		luci.http.prepare_content("application/json")
		luci.http.write_json(e)
	end	