-- Copyright 2021-2022 Michael Zhang <probezy@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"
local nixio = require "nixio"
local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local sys = require "luci.sys"
local json = require "luci.jsonc"


local m, s, o


m = Map("cpolar", "%s - %s" % { translate("Cpolar"), translate("General") },
"<p>%s</p><p>%s</p>" % {
	translate("It is a secure intranet penetration tool. It can easily publish internal websites to the public network, SSH remote home soft routing, remote desktop to office PC, it can simulate the local development environment into a public network environment, convenient For WeChat public number, small programs, OpenAPI development and debugging. Is the development, geek, IT operations staff must be a weapon."),
	translatef("For more information, please visit: %s",
		"<a href=\"https://www.cpolar.com\" target=\"_blank\">https://www.cpolar.com</a>")
})

m:append(Template("cpolar/status_header"))


s = m:section(TypedSection, "general", "")
s.addremove = false
s.anonymous = true


o = s:option(Flag, "enabled", translate("Enabled"))
o.rmempty = false

o = s:option(Button, "_reload", translate("Reload Service"), translate("This will restart service when config file changes."))
o.inputstyle = "reload"
o.write = function ()
	sys.call("/etc/init.d/cpolar reload 2>/dev/null")
end

o = s:option(Value, "authtoken", translate("AuthToken"), translate("cpolar Authtoken, visit cpolar background dashboard to <a href=\"https://dashboard.cpolar.com/auth\" target=\"_blank\">get your authentication token</a> <br/> No account? <a href=\"https://dashboard.cpolar.com/signup\" target=\"_blank\">Sign up for free</a> to get an authentication token"))
o.rmempty = false

return m
