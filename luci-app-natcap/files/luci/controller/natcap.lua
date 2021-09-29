-- Copyright (C) 2019 X-WRT <dev@x-wrt.com>

module("luci.controller.natcap", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/natcapd") then
		return
	end

	local ut = require "luci.util"
	local sys  = require "luci.sys"
	local ui = ut.trim(sys.exec("uci get natcapd.default.ui 2>/dev/null"))

	local page

	if ui == "world" or ui == "simple" then
	page = entry({"admin", "services", "natcap"}, cbi("natcap/natcap"), _("Natcap"))
	page.i18n = "natcap"
	page.dependent = true
	page.acl_depends = { "luci-app-natcap" }
	elseif ui == "sdwan" then
	page = entry({"admin", "natcap_sdwan"}, firstchild(), _("SD-WAN"), 60)
	page.dependent = false
	page.acl_depends = { "luci-app-natcap" }
	page = entry({"admin", "natcap_sdwan", "basic"}, cbi("natcap/natcap_sdwan"), _("Basic"))
	page.i18n = "natcap"
	page.dependent = true
	page.acl_depends = { "luci-app-natcap" }
	page = node("admin", "natcap_sdwan", "activation")
	page.target = template("natcap/natcap_sdwan")
	page.title  = _("TOP UP")
	page = entry({"admin", "natcap_sdwan", "activation_sn"}, post("activation_sn"), nil)
	page.leaf = true
	page.acl_depends = { "luci-app-natcap" }
	else
	page = entry({"admin", "services", "natcap"}, cbi("natcap/natcap_simple"), _("Natcap"))
	page.i18n = "natcap"
	page.dependent = true
	page.acl_depends = { "luci-app-natcap" }
	end

	entry({"admin", "services", "natcap", "get_natcap_flows0"}, call("get_natcap_flows0")).leaf = true
	entry({"admin", "services", "natcap", "get_natcap_flows1"}, call("get_natcap_flows1")).leaf = true
	entry({"admin", "services", "natcap", "get_openvpn_client"}, call("get_openvpn_client")).leaf = true
	entry({"admin", "services", "natcap", "get_openvpn_client_udp"}, call("get_openvpn_client_udp")).leaf = true
	entry({"admin", "services", "natcap", "status"}, call("status")).leaf = true
	entry({"admin", "services", "natcap", "change_server"}, call("change_server")).leaf = true

	page = entry({"admin", "vpn", "natcapd_vpn"}, cbi("natcap/natcapd_vpn"), _("One Key VPN"))
	page.i18n = "natcap"
	page.dependent = true
	page.acl_depends = { "luci-app-natcap" }

	page = entry({"admin", "system", "natcapd_sys"}, cbi("natcap/natcapd_sys"), _("Advanced Options"))
	page.i18n = "natcap"
	page.dependent = true
	page.acl_depends = { "luci-app-natcap" }

	if ui == "simple" then
	page = entry({"admin", "natcap_route"}, cbi("natcap/natcap_route"), _("Route Setup"))
	page.i18n = "natcap"
	page.dependent = true
	elseif ui == "world" then
	page = entry({"admin", "services", "natcap_route"}, cbi("natcap/natcap_route"), _("Route Setup"))
	page.i18n = "natcap"
	page.dependent = true
	end
	page.acl_depends = { "luci-app-natcap" }
end

function activation_sn(sn)
	local reader = ltn12_popen("/usr/sbin/natcapd activation_sn %s" % luci.util.shellquote(sn))

	luci.http.prepare_content("text/plain")
	luci.ltn12.pump.all(reader, luci.http.write)
	return
end

function status()
	local ut = require "luci.util"
	local sys  = require "luci.sys"
	local http = require "luci.http"
	local js = require "cjson.safe"

	local text = ut.trim(sys.exec("cat /dev/natcap_ctl 2>/dev/null"))
	local oldtxrx = ut.trim(sys.exec("cat /tmp/natcapd.txrx 2>/dev/null"))
	local flows = sys.exec("cat /tmp/xx.json 2>/dev/null")

	local oldtx = oldtxrx:gsub("(%w+) (%w+)", "%1")
	local oldrx = oldtxrx:gsub("(%w+) (%w+)", "%2")

	local data = {
		cur_server = text:gsub(".*current_server0=(.-)\n.*", "%1"),
		uhash = text:gsub(".*u_hash=(.-)\n.*", "%1"),
		client_mac = text:gsub(".*default_mac_addr=(..):(..):(..):(..):(..):(..)\n.*", "%1%2%3%4%5%6"),
		total_tx = text:gsub(".*flow_total_tx_bytes=(.-)\n.*", "%1"),
		total_rx = text:gsub(".*flow_total_rx_bytes=(.-)\n.*", "%1"),
	}
	data.total_tx = tonumber(data.total_tx) or 0
	data.total_rx = tonumber(data.total_rx) or 0
	data.uid = data.client_mac .. "-" .. data.uhash
	data.mgr = "http://" .. string.lower(data.client_mac) .. ".x-wrt.dev/"
	data.domain = string.lower(data.client_mac) .. ".dns.x-wrt.com"
	data.client_mac = nil
	data.uhash = nill
	data.flows = js.decode(flows) or {}
	data.flows = data.flows.flows
	if data.flows and data.flows[1] then
		data.flows[1].tx = tonumber(data.flows[1].tx) + data.total_tx - tonumber(oldtx)
		data.flows[1].rx = tonumber(data.flows[1].rx) + data.total_rx - tonumber(oldrx)
	end

	local yy = sys.exec("cat /tmp/yy.json 2>/dev/null")
	yy = js.decode(yy) or {}
	data.exp = os.date('%Y-%m-%d %H:%M:%S', yy.data and yy.data.exp or 0)

	http.prepare_content("application/json")
	http.write_json(data)
end

function change_server()
	local ut = require "luci.util"
	local sys  = require "luci.sys"
	local http = require "luci.http"

	sys.call("echo change_server >/dev/natcap_ctl")

	local text = ut.trim(sys.exec("cat /dev/natcap_ctl 2>/dev/null"))
	local data = {
		cur_server = text:gsub(".*current_server0=(.-)\n.*", "%1"),
	}

	http.prepare_content("application/json")
	http.write_json(data)
end

function get_natcap_flows0()
	local js = require "cjson.safe"
	local sys  = require "luci.sys"
	local now = os.date("*t")
	local from = os.date("%Y%m%d", os.time({year=now.year, month=now.month, day=1}))
	local to = os.date("%Y%m%d")
	local filename = string.format("Flows_%s-%s", from, to)

	local reader = ltn12_popen("/usr/sbin/natcapd get_flows0")

	luci.http.header('Content-Disposition', 'attachment; filename="' .. filename .. '.csv"')
	luci.http.prepare_content("text/csv; charset=UTF-8")
	luci.ltn12.pump.all(reader, luci.http.write)
end

function get_natcap_flows1()
	local sys  = require "luci.sys"
	local js = require "cjson.safe"
	local now = os.date("*t")
	local from = os.date("%Y%m%d", os.time({year=now.year, month=now.month-1, day=1}))
	local to = os.date("%Y%m%d", os.time({year=now.year, month=now.month, day=0}))
	local filename = string.format("Flows_%s-%s", from, to)

	local reader = ltn12_popen("/usr/sbin/natcapd get_flows1")

	luci.http.header('Content-Disposition', 'attachment; filename="' .. filename .. '.csv"')
	luci.http.prepare_content("text/csv; charset=UTF-8")
	luci.ltn12.pump.all(reader, luci.http.write)
end

function get_openvpn_client()
	local reader = ltn12_popen("sh /usr/share/natcapd/natcapd.openvpn.sh gen_client")

	luci.http.header('Content-Disposition', 'attachment; filename="natcap-client-tcp.ovpn"')
	luci.http.prepare_content("application/x-openvpn-profile")
	luci.ltn12.pump.all(reader, luci.http.write)
end

function get_openvpn_client_udp()
	local reader = ltn12_popen("sh /usr/share/natcapd/natcapd.openvpn.sh gen_client_udp")

	luci.http.header('Content-Disposition', 'attachment; filename="natcap-client-udp.ovpn"')
	luci.http.prepare_content("application/x-openvpn-profile")
	luci.ltn12.pump.all(reader, luci.http.write)
end

function ltn12_popen(command)

	local fdi, fdo = nixio.pipe()
	local pid = nixio.fork()

	if pid > 0 then
		fdo:close()
		local close
		return function()
			local buffer = fdi:read(2048)
			local wpid, stat = nixio.waitpid(pid, "nohang")
			if not close and wpid and stat == "exited" then
				close = true
			end

			if buffer and #buffer > 0 then
				return buffer
			elseif close then
				fdi:close()
				return nil
			end
		end
	elseif pid == 0 then
		nixio.dup(fdo, nixio.stdout)
		fdi:close()
		fdo:close()
		nixio.exec("/bin/sh", "-c", command)
	end
end
