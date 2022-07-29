-- Copyright 2008 Yanira <forum-2008@email.de>
-- Licensed to the public under the Apache License 2.0.

require("nixio.fs")

local m
local s
local try_devices = nixio.fs.glob("/dev/tty[A-Z][A-Z]*")
local try_leds = nixio.fs.glob("/sys/class/leds/*")

m = Map("smstools3", translate("Setup smstools3"),
        translate("Configure smstools3 daemon."))

s = m:section(TypedSection, "sms")
s.anonymous = true

utf8 = s:option(Flag, "decode_utf", translate("Decode SMS"),
	translate("Decode Incoming messages to UTF-8 codepage."))
utf8.rmempty = true
ui = s:option(Flag, "ui", translate("Unexepted Input"),
	translate("Enable Unexpected input from COM port."))
ui.rmempty = true
dt = s:option(Value, "delay", translate("Delay time"),
	translate("Default value: 10<br />Smsd sleep so many seconds when it has nothing to do."))
dt.rmempty = true

memory = s:option(ListValue, "storage", translate("SMS Storage"),
	translate("Select storage to save SMS."))
memory:value("temporary", translate("Temporary"))
memory:value("persistent", translate("Persistent"))
memory.default = "temporary"
memory.rmempty = true

dev = s:option(ListValue, "device", translate("Device"),
	translate("Select COM port."))
if try_devices then
	local node
	for node in try_devices do
		dev:value(node, node)
	end
end

init = s:option(ListValue, "init", translate("Init string"),
                translate("Initialise modem for more vendors"))
init:value("huawei", "Huawei")
init:value("intel", "Intel XMM")
init:value("", "Qualcomm or more")
init.default = ""
init.rempty = true

pin = s:option(Value, "pin", translate("PIN Code"),
		translate("Default value: not in use.<br />Specifies the PIN number of the SIM card inside the modem."))
pin.rmempty = true

net = s:option(ListValue, "net_check", translate("Check network"),
		translate("Setup network checking. Some modems incorrect test network."))
net:value("0", translate("Ignore check"))
net:value("1", translate("Always check"))
net:value("2", translate("Check prepare message"))

sig = s:option(Flag, "sig_check", translate("Ignore signal level"),
		translate("Some devices do not support Bit Error Rate"))

log = s:option(ListValue, "loglevel", translate("Loglevel"),
		translate("Verbose logging output."))
log:value("1", "Emergency")
log:value("2", "Alert")
log:value("3", "Critical")
log:value("4", "Error")
log:value("5", "Warning")
log:value("6", "Notice")
log:value("7", "Info")
log:value("8", "Debug")
log.default = "5"

led_enable = s:option(Flag, "led_enable", translate("LED"),
		translate("Enable LED indication incoming messages."))

led = s:option(ListValue, "led", translate("Select LED"),
		translate("LED indicate to Incoming messages.<br />To revert, setup led \"System -> LED Configuration\" again."))

led:depends("led_enable", 1)
if try_leds then
	local flash
	local status
	for flash in try_leds do
		local status = flash
		local flash = string.sub (status, 17)
		led:value(flash,flash)
	end
end

function m.on_after_commit(Map)
	luci.sys.call("/usr/bin/luci-app-smstools3")
end

return m
