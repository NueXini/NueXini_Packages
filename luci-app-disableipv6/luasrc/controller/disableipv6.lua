module("luci.controller.disableipv6", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/disableipv6") then
			return
	end
	
	entry({"admin", "network", "disableipv6"}, cbi("disableipv6"), _("Disable IPV6"), 99).dependent = true
end