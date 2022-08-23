-- Copyright 2020 Rafał Wabik (IceG) - From eko.one.pl forum
-- Licensed to the GNU General Public License v3.0.


	local util = require "luci.util"
	local fs = require "nixio.fs"
	local sys = require "luci.sys"
	local http = require "luci.http"
	local dispatcher = require "luci.dispatcher"
	local http = require "luci.http"
	local sys = require "luci.sys"
	local uci = require "luci.model.uci".cursor()

module("luci.controller.modem.atc", package.seeall)

function index()
	entry({"admin", "modem"}, firstchild(), "Modem", 45).acl_depends={"unauthenticated"}
	entry({"admin", "modem", "atc"}, alias("admin", "modem", "atc", "atcommand"), translate("AT Commands"), 40).acl_depends={"unauthenticated"}
 	entry({"admin", "modem", "atc", "atcommand"},template("modem/atcommand"),translate("AT Commands"), 41).acl_depends={"unauthenticated"}
	entry({"admin", "modem", "atc", "atconfig"},cbi("modem/atconfig"),translate("Configuration"), 42).acl_depends={"unauthenticated"}
	entry({"admin", "modem", "webcmd"}, call("webcmd"))
	entry({"admin", "modem", "atc", "user_atc"}, call("useratc"), nil).leaf = true

end


function webcmd()
    local cmd = http.formvalue("cmd")
    if cmd then
	    local at = io.popen("/usr/bin/luci-app-atinout " ..cmd:gsub("[$]", "\\\$"):gsub("\"", "\\\"").." 2>&1")
	    local result =  at:read("*a")
	    at:close()
        http.write(tostring(result))
    else
        http.write_json(http.formvalue())
    end
end

function uussd(rv)
	local c = nixio.fs.access("/etc/atcommands.user") and
		io.popen("cat /etc/atcommands.user")

	if c then
		for l in c:lines() do
			local i = l
			if i then
				rv[#rv + 1] = {
					usd = i
				}
			end
		end
		c:close()
	end
end



function useratc()
	local usd = { }
	uussd(usd)
	luci.http.prepare_content("application/json")
	luci.http.write_json(usd)
end
