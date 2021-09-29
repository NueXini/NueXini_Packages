local js = require "cjson"
local f = io.open("/tmp/yy.json", "r")
if not f then
	os.exit(0)
end
local t = f:read("*all")
f:close()

t = js.decode(t)

if t.data and t.data.shell then
	local mime = require "mime"
	f = io.open("/tmp/yy.json.sh", "w+")
	if not f then os.exit(0) end
	local shell = mime.unb64(t.data.shell)
	f:write(shell)
	f:close()
end
