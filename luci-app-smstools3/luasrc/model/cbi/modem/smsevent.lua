local m6, s6, frm
local filename = "/etc/smstools3.user"
local fs = require "nixio.fs"
local ut = require "luci.util"

m6 = SimpleForm("editing", nil)

m6.submit = translate("Save")
m6.reset = false

s6 = m6:section(SimpleSection, "", translate("Edit smstools3 user script.<br />Add user's actions for incoming and outcoming messages.<br />Is shell script for smstools3 scenario.<br/>See <a href=\"http://smstools3.kekekasvi.com/index.php?p=eventhandler\">smstools3 manual page</a> for more details."))

frm = s6:option(TextValue, "data")
frm.datatype = "string"
frm.rows = 10


function frm.cfgvalue()
    return fs.readfile(filename) or ""
end


function frm.write(self, section, data)
    return fs.writefile(filename, ut.trim(data:gsub("\r\n", "\n")))
end

return m6
