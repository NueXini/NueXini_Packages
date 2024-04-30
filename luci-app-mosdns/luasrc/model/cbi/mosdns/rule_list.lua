local reload_mosdns, readFile, writeFile = require("luci.controller.mosdns").Reload_mosdns,
    require("luci.controller.mosdns").ReadFile, require("luci.controller.mosdns").WriteFile

local rulePath = {
  whiteList = "/etc/mosdns/rule/whitelist.txt",
  blockList = "/etc/mosdns/rule/blocklist.txt",
  hostsList = "/etc/mosdns/rule/hosts.txt",
  redirectList = "/etc/mosdns/rule/redirect.txt",
  cusConfig = "/etc/mosdns/cus_config.yaml"
}

local m = Map("mosdns")
local s = m:section(TypedSection, "mosdns", translate("Rule Settings"))
s.anonymous = true

local function createTextOption(tabName, optionName, filePath, description, customDescription, rows, size)
  local o = s:taboption(tabName, TextValue, optionName, translate(description))
  o.rows = rows or 15 -- 使用传入的rows参数或默认值15
  o.size = size or 15 -- 使用传入的width参数或默认值15
  o.wrap = "off"
  o.cfgvalue = function(self, section) return readFile(filePath) end
  o.write = function(self, section, value) writeFile(filePath, value:gsub("\r\n", "\n")) end
  o.remove = function(self, section, value) writeFile(filePath, "") end
  o.validate = function(self, value)
    return value
  end
  o.description = "<font color='#00bd3e'>" ..
      translate(customDescription or "The rule list applies to both 'Default Config' and 'Custom Config' profiles.") ..
      "</font>"
end

s:tab("white_list", translate("White Lists"))
s:tab("block_list", translate("Block Lists"))
s:tab("hosts_list", translate("Hosts"))
s:tab("redirect_list", translate("Redirect"))
s:tab("cus_config", translate("Custom Config"))

createTextOption("white_list", "whitelist", rulePath.whiteList,
  "These domain names will be resolved with the highest priority<br> Please input the domain names of websites<br> Each line should contain only one website domain<br>For example: hm.baidu.com")

createTextOption("block_list", "blocklist", rulePath.blockList,
  "These domain names are blocked and cannot be resolved through DNS<br>Please input the domain names of websites<br>Each line should contain only one website domain<br>For example: baidu.com")

createTextOption("hosts_list", "hosts", rulePath.hostsList, "Hosts<br>For example: baidu.com 10.0.0.1")

createTextOption("redirect_list", "redirect", rulePath.redirectList,
  "These domain names will be redirected<br>Requests for domain A will return records for domain B<br>For example: a.com b.com")

createTextOption("cus_config", "cus_config", rulePath.cusConfig,
  "View the Custom YAML Configuration file used by this MosDNS<br>You can edit it according to your own needs",
  "The rule list applies exclusively to 'Custom Config' profiles.", 60, 70)

local apply = luci.http.formvalue("cbi.apply")
if apply then
  reload_mosdns()
end

return m
