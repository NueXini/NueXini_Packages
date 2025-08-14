require("luci.sys")

m = Map("qiyougamebooster", translate("QiYou Game Booster"),
	translate("Play console games online with less lag and more stability.") .. "<br />" ..
	translate("— now supporting PS, Switch, Xbox, PC, and mobile."))

s = m:section(TypedSection, "qiyougamebooster")
s.anonymous = true
s.addremove = false

sts = luci.sys.exec("qiyougamebooster.sh status 2> /dev/null")
ver = luci.sys.exec("qiyougamebooster.sh version 2> /dev/null")
o = s:option(DummyValue, "status")
o.rawhtml = true
if sts == "NOT ENABLED" or sts == "NOT SUPPORTED" or sts == "NOT RUNNING" then
	o.value = string.format('<span style="color:%s"><strong>%s: %s %s</strong></span>', "red", translate("Status"), ver, translate(sts))
else
	o.value = string.format('<span style="color:%s"><strong>%s: %s %s</strong></span>', "green", translate("Status"), ver, translate(sts))
end

o = s:option(Flag, "enabled", translate("Enable"))
o.default = 0

o = s:option(DummyValue, "instructions")
o.rawhtml = true
o.value = "<p><img src='/qiyougamebooster/Tutorial.png' height='350'/></p>"

return m
