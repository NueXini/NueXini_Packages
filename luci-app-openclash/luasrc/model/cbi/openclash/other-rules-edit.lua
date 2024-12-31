
local m, s, o
local openclash = "openclash"
local uci = luci.model.uci.cursor()
local fs = require "luci.openclash"
local sys = require "luci.sys"
local sid = arg[1]

font_red = [[<b style=color:red>]]
font_green = [[<b style=color:green>]]
font_off = [[</b>]]
bold_on  = [[<strong>]]
bold_off = [[</strong>]]

function IsYamlFile(e)
   e=e or""
   local e=string.lower(string.sub(e,-5,-1))
   return e == ".yaml"
end
function IsYmlFile(e)
   e=e or""
   local e=string.lower(string.sub(e,-4,-1))
   return e == ".yml"
end

m = Map(openclash, translate("Other Rules Edit"))
m.pageaction = false
m.redirect = luci.dispatcher.build_url("admin/services/openclash/config-overwrite")
if m.uci:get(openclash, sid) ~= "other_rules" then
	luci.http.redirect(m.redirect)
	return
end

-- [[ Other Rules Setting ]]--
s = m:section(NamedSection, sid, "other_rules")
s.anonymous = true
s.addremove   = false

o = s:option(Value, "Note", translate("Note"))
o.default = "default"
o.rmempty = false

o = s:option(ListValue, "config", translate("Config File"))
local e,a={}
local groupnames,filename
for t,f in ipairs(fs.glob("/etc/openclash/config/*"))do
	a=fs.stat(f)
	if a then
    e[t]={}
    e[t].name=fs.basename(f)
    if IsYamlFile(e[t].name) or IsYmlFile(e[t].name) then
       o:value(e[t].name)
    end
    if e[t].name == m.uci:get(openclash, sid, "config") then
    	filename = e[t].name
      groupnames = sys.exec(string.format('ruby -ryaml -rYAML -I "/usr/share/openclash" -E UTF-8 -e "YAML.load_file(\'%s\')[\'proxy-groups\'].each do |i| puts i[\'name\']+\'##\' end" 2>/dev/null',f))
    end
  end
end

o = s:option(Button, translate("Get Group Names"))
o.title = translate("Get Group Names")
o.inputtitle = translate("Get Group Names")
o.description = translate("Get Group Names After Select Config File")
o.inputstyle = "reload"
o.write = function()
  m.uci:commit("openclash")
  luci.http.redirect(luci.dispatcher.build_url("admin/services/openclash/other-rules-edit/%s") % sid)
end

if groupnames ~= nil and filename ~= nil then
o = s:option(ListValue, "rule_name", translate("Other Rules Name"))
o.rmempty = true
o:value("lhie1", translate("lhie1 Rules"))

o = s:option(ListValue, "GlobalTV", translate("GlobalTV"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "AsianTV", translate("AsianTV"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "MainlandTV", translate("CN Mainland TV"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Proxy", translate("Proxy"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Youtube", translate("Youtube"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Bilibili", translate("Bilibili"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Bahamut", translate("Bahamut"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "HBOMax", translate("HBO Max"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Pornhub", translate("Pornhub"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Apple", translate("Apple"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "AppleTV", translate("Apple TV"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "GoogleFCM", translate("Google FCM"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Scholar", translate("Scholar"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Microsoft", translate("Microsoft"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "AI_Suite", translate("AI Suite"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Netflix", translate("Netflix"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Disney", translate("Disney Plus"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Discovery", translate("Discovery Plus"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "DAZN", translate("DAZN"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Spotify", translate("Spotify"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Steam", translate("Steam"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "miHoYo", translate("miHoYo"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Speedtest", translate("Speedtest"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Telegram", translate("Telegram"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Crypto", translate("Crypto"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Discord", translate("Discord"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "PayPal", translate("PayPal"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "AdBlock", translate("AdBlock"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "HTTPDNS", translate("HTTPDNS"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Domestic", translate("Domestic"))
o:depends("rule_name", "lhie1")
o.rmempty = true
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

o = s:option(ListValue, "Others", translate("Others"))
o:depends("rule_name", "lhie1")
o.rmempty = true
o.description = translate("Choose Proxy Groups, Base On Your Config File").." ( "..font_green..bold_on..filename..bold_off..font_off.." )"
for groupname in string.gmatch(groupnames, "([^'##\n']+)##") do
  if groupname ~= nil and groupname ~= "" then
    o:value(groupname)
  end
end
o:value("DIRECT")
o:value("REJECT")

end

local t = {
  {Commit, Back}
}
a = m:section(Table, t)

o = a:option(Button,"Commit", " ")
o.inputtitle = translate("Commit Settings")
o.inputstyle = "apply"
o.write = function()
  m.uci:commit(openclash)
  --luci.http.redirect(m.redirect)
end

o = a:option(Button,"Back", " ")
o.inputtitle = translate("Back Settings")
o.inputstyle = "reset"
o.write = function()
  m.uci:revert(openclash, sid)
  luci.http.redirect(m.redirect)
end

m:append(Template("openclash/toolbar_show"))
return m
