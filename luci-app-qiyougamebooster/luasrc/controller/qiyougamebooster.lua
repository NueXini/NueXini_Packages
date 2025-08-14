module("luci.controller.qiyougamebooster", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/qiyougamebooster") then
		return
	end

	local page
	page = entry({"admin", "services", "qiyougamebooster"}, cbi("qiyougamebooster"), ("QiYou Game Booster"), 99)
	page.dependent = false
	page.acl_depends = {"luci-app-qiyougamebooster"}
end
