module("luci.controller.mosdns", package.seeall)

local sys = require("luci.sys")
local http = require("luci.http")
local util = require("luci.util")

local function write_json_response(data, content_type)
    http.prepare_content(content_type)
    http.write_json(data)
end

local function handle_file_content(file_path, write)
    local file = io.open(file_path, write and "r" or "w")
    if file then
        local content = file:read("*a")
        file:close()
        if write then
            http.write(content)
        end
    end
end

local function is_mosdns_running()
    local result = sys.exec("pgrep -f mosdns")
    return result ~= ""
end

function ReadFile(filePath, checkExistence)
    local file = io.open(filePath, "r")
    if not file then
        util.perror("Failed to read file: " .. filePath)
        return false
    else
        if checkExistence then
            return true
        else
            local content = file:read("*a")
            file:close()
            return content
        end
    end
end

function WriteFile(filePath, content)
    local file = io.open(filePath, "w")
    if not file then
        util.perror("Failed to write file: " .. filePath)
        return
    end

    file:write(content)
    file:close()
end

function Reload_mosdns()
    local output = sys.exec("/etc/init.d/mosdns reload")
    if output ~= "" then
        util.perror("Failed to reload MosDNS. Error: " .. output)
    end
end

function Act_status()
    local status = {
        running = is_mosdns_running()
    }
    write_json_response(status, "application/json")
end

function Get_log()
	luci.http.write(luci.sys.exec("cat $(/usr/share/mosdns/mosdns.sh logfile)"))
end

function Clear_log()
	luci.sys.call("cat /dev/null > $(/usr/share/mosdns/mosdns.sh logfile)")
end

function index()
    local function check_config_file()
        local readFile = require("luci.controller.mosdns").ReadFile
        local filePath = "/etc/config/mosdns"
        local exists = readFile(filePath, true)
        return exists
    end

    if not check_config_file() then
        return
    end

    local mosdns_page = entry({ "admin", "services", "mosdns" }, alias("admin", "services", "mosdns", "basic"),
        _("MosDNS"), 30)
    mosdns_page.dependent = true
    mosdns_page.acl_depends = { "luci-app-mosdns" }

    entry({ "admin", "services", "mosdns", "basic" }, cbi("mosdns/basic"), _("Basic Setting"), 1).leaf = true
    entry({ "admin", "services", "mosdns", "rule_list" }, cbi("mosdns/rule_list"), _("Rule List"), 2).leaf = true
    entry({ "admin", "services", "mosdns", "update" }, cbi("mosdns/update"), _("Geodata Update"), 3).leaf = true
    entry({ "admin", "services", "mosdns", "log" }, cbi("mosdns/log"), _("Logs"), 4).leaf = true
    entry({ "admin", "services", "mosdns", "status" }, call("Act_status")).leaf = true
    entry({ "admin", "services", "mosdns", "get_log" }, call("Get_log")).leaf = true
    entry({ "admin", "services", "mosdns", "clear_log" }, call("Clear_log")).leaf = true
end
