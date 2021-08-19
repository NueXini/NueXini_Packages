module("luci.controller.tencentddns",package.seeall)
function index()
    local page = entry({"admin", "tencentcloud"}, firstchild(), "腾讯云设置")
    page.order = 30
    page.dependent = false
    page.acl_depends = { "luci-app-tencentddns" }
    entry({"admin", "tencentcloud", "tencentddns"},cbi("tencentddns"),_("TencentDDNS"),2)
end
