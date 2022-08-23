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

local ATC_FILE_PATH = "/etc/atcommands.user"

local m
local s
local dev1
local try_devices1 = nixio.fs.glob("/dev/tty[A-Z][A-Z]*")

m = Map("atinout", translate("Atinout Configuration"),
	translate("Configuration panel for atinout."))

s = m:section(NamedSection, 'general' , "atinout" , "<p>&nbsp;</p>" .. translate("AT Commands Terminal Settings"))
s.anonymous = true

dev1 = s:option(Value, "atcport", translate("AT Command Sending Port"))
if try_devices1 then
local node
for node in try_devices1 do
dev1:value(node, node)
end
end

local atc = s:option(TextValue, "user_atcommands", translate("User AT Commands"), translate("Each line must have the following format: 'AT Command name;AT Command'. Save to file '/etc/atcommands.user'."))
atc.rows = 20
atc.rmempty = false

function atc.cfgvalue(self, section)
    return fs.readfile(ATC_FILE_PATH)
end

function atc.write(self, section, value)
    		value = value:gsub("\r\n", "\n")
    		fs.writefile(ATC_FILE_PATH, value)
end

return m
