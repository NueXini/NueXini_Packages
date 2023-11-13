module("luci.controller.webdav", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/webdav") then
		return
	end

	entry({"admin", "nas", "webdav"}, cbi("webdav"), _("Webdav")).dependent = true
	entry({"admin", "nas", "webdav", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e = {}
	e.running = luci.sys.call("pgrep webdav >/dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end
