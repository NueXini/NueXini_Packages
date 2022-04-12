local nixio = require "nixio"

module("luci.controller.modem.smstools3", package.seeall)

local utl = require "luci.util"

function index()
	entry({"admin", "modem"},  firstchild(), "Modem", 45).acl_depends={"unauthenticated"}
	entry({"admin", "modem", "sms"}, alias ("admin", "modem", "sms", "in_sms"), translate("Smstools3 SMS"), 11).acl_depends={"unauthenticated"}
	entry({"admin", "modem", "sms", "in_sms"}, template("modem/sms/in"), translate("Incoming"), 22).acl_depends={"unauthenticated"}
	entry({"admin", "modem", "sms", "out_sms"}, template("modem/sms/out"), translate("Outcoming"),23).acl_depends={"unauthenticated"}
	entry({"admin", "modem", "sms", "send_sms"}, template("modem/sms/send"), translate("Push"), 24).acl_depends={"unauthenticated"}
	entry({"admin", "modem", "sms", "setup_sms"}, cbi("modem/smstools3"), translate("Setup"), 25).acl_depends={"unauthenticated"}
	entry({"admin", "modem", "sms", "event"}, form("modem/smsevent"), translate("User Script"), 26).acl_depends={"unauthenticated"}
	entry({"admin", "modem", "push_sms"}, call("action_send_sms"))
	entry({"admin", "modem", "erase_in_sms"}, call("action_in_erase_sms"))
	entry({"admin", "modem", "erase_out_sms"}, call("action_out_erase_sms"))
end


function action_send_sms()
	local set = luci.http.formvalue("set")
	number = (string.sub(set, 1, 20))
	txt = string.sub(set, 21)
	message = string.gsub(txt, "\n", " ")
	os.execute("/usr/bin/sendsms " ..number.." '"..message.."'")
end

function action_in_erase_sms()
	local set = luci.http.formvalue("erase_in_sms")
	os.execute("rm -f /var/spool/sms/incoming/*")
end

function action_out_erase_sms()
        local set = luci.http.formvalue("erase_out_sms")
        os.execute("rm -f /var/spool/sms/sent/*")
end
