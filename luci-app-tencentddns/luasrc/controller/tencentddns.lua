module("luci.controller.tencentddns",package.seeall)
function index()
    local page = entry({"admin", "services", "tencentddns"},cbi("tencentddns"),_("TencentDDNS"))
    page.order = 30
    page.dependent = false
    page.acl_depends = { "luci-app-tencentddns" }
end
