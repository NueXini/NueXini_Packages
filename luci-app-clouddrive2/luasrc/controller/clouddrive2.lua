module("luci.controller.clouddrive2", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/clouddrive2") then
        return
    end
	entry({"admin", "nas"}, firstchild(), _("NAS"), 45).dependent = false
	entry({"admin","nas","clouddrive2"},cbi("clouddrive2"),_("CloudDrive2"), 10).acl_depends = { "luci-app-clouddrive2" }
    entry({"admin", "nas", "clouddrive2", "status"}, call("act_status")).leaf = true
end

function act_status()
  local e={}
  e.running=luci.sys.call("pgrep clouddrive >/dev/null")==0
  luci.http.prepare_content("application/json")
  luci.http.write_json(e)
end
