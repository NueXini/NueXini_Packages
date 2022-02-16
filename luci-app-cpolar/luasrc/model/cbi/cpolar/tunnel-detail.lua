-- Copyright 2021-2022 Michael Zhang <probezy@gmail.com>
-- Licensed to the public under the MIT License.

local dsp = require "luci.dispatcher"
local nixio = require "nixio"
local util = require "luci.util"


function strip_spaces(value)
	str = string.gsub(value, '[ \t]+%f[\r\n%z]', '')
	return str
end


local m, s, o

local sid = arg[1]

m = Map("cpolar", "%s - %s" % { translate("Cpolar"), translate("Edit Tunnel") },
	translatef("Details: %s", "<a href=\"https://www.cpolar.com/en/configuration/overview.html#tunnel\" target=\"_blank\">TunnelObject</a>"))
m.redirect = dsp.build_url("admin/services/cpolar/tunnels")

if m.uci:get("cpolar", sid) ~= "tunnel" then
	luci.http.redirect(m.redirect)
	return
end




s = m:section(NamedSection, sid, "tunnel")
s.addremove = false


s:tab("basic", translate("Basic Settings"), nil )
s:tab("advanced", translate("Advanced Settings"), nil )


-- TAB: Basic  #####################################################################################


o = s:taboption("basic",Flag, "enabled", translate("Enabled"))
o.rmempty = false
o.default=1

o = s:taboption("basic", ListValue, "proto", translate("Protocol"), translate("Tunnel protocol name, http, tcp optional."))
o:value("http", "HTTP")
o:value("tcp", "TCP")

--o:value("ftp", "FTP")
--o:value("nas", "NAS")
--o:value("tls", "TLS")


o = s:taboption("basic", Value, "addr", translate("Address"), translate("Forward traffic to the local port number or network address"))
o.rmempty = false
o.datatype = "or(port, string)"
o.placeholder = "8080"

o = s:taboption("basic", ListValue, "region", translate("Region"), translate("Global geographic region"))
o:value("", translate("Default"))
o:value("us", translate("United States"))
o:value("cn", translate("China"))
o:value("cn_vip", translate("China VIP"))
o:value("cn_top", translate("China Top"))
o:value("hk", translate("HongKong"))
o:value("tw", translate("TaiWan"))
o:value("eu", translate("Europe"))

-- Settings - TCP

-- TAB: tcp Basic  #####################################################################################
o = s:taboption("basic", ListValue, "portType", translate("Port Type"), translate("TCP Address Type"))
o:value("randPort", translate("Random Port Address"))
o:value("fixedPort", translate("Fixed Port Address"))
o:depends("proto", "tcp")

o = s:taboption("basic", Value, "remote_addr", translate("Remote Addr"), translate("The public TCP address and port number that are retained"))
o:depends("portType", "fixedPort")

-- Settings - HTTP


-- TAB: Http Basic  #####################################################################################

o = s:taboption("basic", ListValue, "domainType", translate("Domain Type"), translate("Domain Type"))
o:value("randDomain", translate("Random Domain"))
o:value("subDomain", translate("Sub Domain"))
o:value("custDomain", translate("Custom Domain"))
o:depends("proto", "http")


-- Settings subdomain
o = s:taboption("basic", Value, "subdomain",translate("Sub Domain"), translate("The child domain name to request"))
o:depends("domainType", "subDomain")
o.datatype = "hostname"

-- Settings Cust Domain
o = s:taboption("basic", Value, "hostname",translate("Hostname"), translate("Custom domain name"))
o:depends("domainType", "custDomain")
o.datatype = "host"

o = s:taboption("basic", Value, "crt",translate("Crt"), translate("HTTPS key certificate"))
o:depends("domainType", "custDomain")

o = s:taboption("basic", Value, "key",translate("Key"), translate("The private key on this path of PEM TLS"))
o:depends("domainType", "custDomain")

o = s:taboption("advanced", Value, "client_cas",translate("Client Cas"), translate("The PEM TLS certification authority on this path verifies the incoming TLS client connection certificate."))
o:depends("domainType", "custDomain")


-- TAB: Http Advaced  #####################################################################################


o = s:taboption("advanced", ListValue, "inspect", translate("Inspect"), translate("Enable listening for HTTP requests"))
o:depends("proto", "http")
o:value("")
o:value("true")
o:value("false")


o =  s:taboption("advanced", Value, "auth",translate("Auth"), translate("HTTP basic authentication credentials to enforce tunnel requests"))
o:depends("proto", "http")

o =  s:taboption("advanced", Value, "host_header",translate("Host Header"), translate("Rewrite the HTTP Host header to this value, or leave it unchanged"))
o:depends("proto", "http")

o = s:taboption("advanced", ListValue, "bind_tls", translate("Bind TLS"), translate("bind an HTTPS or HTTP endpoint or both true, false, or both"))
o:depends("proto", "http")
o:value("")
o:value("true")
o:value("false")
o:value("both")

o = s:taboption("advanced", ListValue, "disable_keep_alives", translate("Disable Keep Alives"), translate("disable Keep Alives for true, default false."))
o:depends("proto", "http")
o:value("")
o:value("true")
o:value("false")

o = s:taboption("advanced", ListValue, "redirect_https", translate("Redirect Https"), translate("Redirect the Web site http request to the http protocol with the domain name site for true"))
o:depends("proto", "http")
o:value("")
o:value("true")
o:value("false")

return m




