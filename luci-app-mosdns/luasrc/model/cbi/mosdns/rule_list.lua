local datatypes = require "luci.cbi.datatypes"

local rule_files = {
  white_list = "/etc/mosdns/rule/whitelist.txt",
  block_list = "/etc/mosdns/rule/blocklist.txt",
  hosts_list = "/etc/mosdns/rule/hosts.txt",
  redirect_list = "/etc/mosdns/rule/redirect.txt",
  cus_config = "/etc/mosdns/cus_config.yaml"
}

local function read_file(file_path)
  local file = io.open(file_path, "r")
  if file then
    local content = file:read("*a")
    file:close()
    return content
  end
  return ""
end

local function write_file(file_path, content)
  local file = io.open(file_path, "w")
  if file then
    file:write(content)
    file:close()
  end
end

local function remove_file(file_path)
  write_file(file_path, "")
end

m = Map("mosdns")

s = m:section(TypedSection, "mosdns", translate("Rule Settings"))
s.anonymous = true

s:tab("white_list", translate("White Lists"))
s:tab("block_list", translate("Block Lists"))
s:tab("hosts_list", translate("Hosts"))
s:tab("redirect_list", translate("Redirect"))
s:tab("cus_config", translate("Cus Config"))

o = s:taboption("white_list", TextValue, "whitelist", "", "<font color='red'>" .. translate("These domain names allow DNS resolution with the highest priority. Please input the domain names of websites, every line can input only one website domain. For example: hm.baidu.com.") .. "</font>" .. "<font color='#00bd3e'>" .. translate("<br>The list of rules only apply to 'Default Config' profiles.") .. "</font>")
o.rows = 15
o.wrap = "off"
o.cfgvalue = function(self, section) return read_file(rule_files.white_list) end
o.write = function(self, section, value) write_file(rule_files.white_list, value:gsub("\r\n", "\n")) end
o.remove = function(self, section, value) remove_file(rule_files.white_list) end
o.validate = function(self, value)
  return value
end

o = s:taboption("block_list", TextValue, "blocklist", "", "<font color='red'>" .. translate("These domains are blocked from DNS resolution. Please input the domain names of websites, every line can input only one website domain. For example: baidu.com.") .. "</font>" .. "<font color='#00bd3e'>" .. translate("<br>The list of rules only apply to 'Default Config' profiles.") .. "</font>")
o.rows = 15
o.wrap = "off"
o.cfgvalue = function(self, section) return read_file(rule_files.block_list) end
o.write = function(self, section, value) write_file(rule_files.block_list, value:gsub("\r\n", "\n")) end
o.remove = function(self, section, value) remove_file(rule_files.block_list) end
o.validate = function(self, value)
  return value
end

o = s:taboption("hosts_list", TextValue, "hosts", "", "<font color='red'>" .. translate("Hosts For example: baidu.com 10.0.0.1") .. "</font>" .. "<font color='#00bd3e'>" .. translate("<br>The list of rules only apply to 'Default Config' profiles.") .. "</font>")
o.rows = 15
o.wrap = "off"
o.cfgvalue = function(self, section) return read_file(rule_files.hosts_list) end
o.write = function(self, section, value) write_file(rule_files.hosts_list, value:gsub("\r\n", "\n")) end
o.remove = function(self, section, value) remove_file(rule_files.hosts_list) end
o.validate = function(self, value)
  return value
end

o = s:taboption("redirect_list", TextValue, "redirect", "", "<font color='red'>" .. translate("The domain name to redirect the request to. Requests domain A, but returns records for domain B. example: a.com b.com") .. "</font>" .. "<font color='#00bd3e'>" .. translate("<br>The list of rules only apply to 'Default Config' profiles.") .. "</font>")
o.rows = 15
o.wrap = "off"
o.cfgvalue = function(self, section) return read_file(rule_files.redirect_list) end
o.write = function(self, section, value) write_file(rule_files.redirect_list, value:gsub("\r\n", "\n")) end
o.remove = function(self, section, value) remove_file(rule_files.redirect_list) end
o.validate = function(self, value)
  return value
end

o = s:taboption("cus_config", TextValue, "Cus Config", "", "<font color='red'>" .. translate("View the Custom YAML Configuration file used by this MosDNS. You can edit it as you own need.") .. "</font>" .. "<font color='#00bd3e'>" .. translate("<br>The list of rules only apply to 'Custom Config' profiles.") .. "</font>")
o.rows = 30
o.wrap = "off"
o.cfgvalue = function(self, section) return read_file(rule_files.cus_config) end
o.write = function(self, section, value) write_file(rule_files.cus_config, value:gsub("\r\n", "\n")) end
o.remove = function(self, section, value) remove_file(rule_files.cus_config) end
o.validate = function(self, value)
  return value
end

local apply = luci.http.formvalue("cbi.apply")
if apply then
  luci.sys.exec("/etc/init.d/mosdns reload")
end

return m