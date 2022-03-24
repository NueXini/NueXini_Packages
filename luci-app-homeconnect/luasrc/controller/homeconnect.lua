module("luci.controller.homeconnect",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/homeconnect")then
		return
	end
	
	entry({"admin","vpn"}, firstchild(), "VPN", 45).dependent = false
	entry({"admin","vpn","homeconnect"},cbi("homeconnect"),_("Home Connect"),49).dependent=true
	entry({"admin","vpn","homeconnect","status"},call("status")).leaf=true
	entry({"admin","vpn","homeconnect","listUser"},call("listUser")).leaf=true
	entry({"admin","vpn","homeconnect","createUser"},call("createUser")).leaf=true
	entry({"admin","vpn","homeconnect","updateUser"},call("updateUser")).leaf=true
	entry({"admin","vpn","homeconnect","deleteUser"},call("deleteUser")).leaf=true
	entry({"admin","vpn","homeconnect","getIPsecInfo"},call("getIPsecInfo")).leaf=true
	entry({"admin","vpn","homeconnect","setIPSecInfo"},call("setIPSecInfo")).leaf=true
end

function status()
	local e={}
	e.status=luci.sys.call("pidof %s >/dev/null"%"vpnserver")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function listUser()
	local t = io.popen("node /usr/share/homeconnect/listUser.js")
	local a = t:read("*all")
	luci.http.prepare_content("application/json")
	luci.http.write(a)
end

function createUser()
	local user=luci.http.formvalue("user")
	local pass=luci.http.formvalue("pass")
	local t = io.popen("node /usr/share/homeconnect/createUser.js "..user.." "..pass)
	local a = t:read("*all")
	luci.http.prepare_content("application/json")
	luci.http.write(a)
end

function updateUser()
	local user=luci.http.formvalue("user")
	local pass=luci.http.formvalue("pass")
	local t = io.popen("node /usr/share/homeconnect/updateUser.js "..user.." "..pass)
	local a = t:read("*all")
	luci.http.prepare_content("application/json")
	luci.http.write(a)
end

function deleteUser()
	local user=luci.http.formvalue("user")
	local t = io.popen("node /usr/share/homeconnect/deleteUser.js "..user)
	local a = t:read("*all")
	luci.http.prepare_content("application/json")
	luci.http.write(a)
end

function getIPsecInfo()
	local t = io.popen("node /usr/share/homeconnect/getIPSecInfo.js")
	local a = t:read("*all")
	luci.http.prepare_content("application/json")
	luci.http.write(a)
end

function setIPSecInfo()
	local ipsecPreSharedKey=luci.http.formvalue("ipsecPreSharedKey")
	local t = io.popen("node /usr/share/homeconnect/setIPSecInfo.js "..ipsecPreSharedKey)
	local a = t:read("*all")
	luci.http.prepare_content("application/json")
	luci.http.write(a)
end
