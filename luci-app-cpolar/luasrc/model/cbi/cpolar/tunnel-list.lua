-- Copyright 2021-2022 Michael Zhang <probezy@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"

local m, s, o

m = Map("cpolar", "%s - %s" % { translate("Cpolar"), translate("Tunnels List") })

s = m:section(TypedSection, "tunnel")
s.sectionhead = translate("Configuration")
s.addremove = true
s.template = "cbi/tblsection"
s.extedit = dsp.build_url("admin/services/cpolar/tunnels/%s")
s.create = function (self, name)
	local sid = TypedSection.create(self, name)
	if sid then
		-- m.uci:save("cpolar")
		luci.http.redirect(s.extedit:format(name))
		return
	end
end

-- function ts.create(self, name)
-- 	AbstractSection.create(self, name)
-- 	HTTP.redirect( self.extedit:format(name) )
-- end

o = s:option(DummyValue, "proto", translate("Protocol"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "addr", translate("Address"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end

o = s:option(DummyValue, "enabled", translate("Enabled"))
o.cfgvalue = function (...)
	return Value.cfgvalue(...) or "?"
end


return m

