local api = require "luci.passwall.api"
local appname = "passwall"

f = SimpleForm(appname)
f.reset = false
f.submit = false
f:append(Template(appname .. "/log/log"))
return f
