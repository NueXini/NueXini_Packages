module("luci.controller.mosdns", package.seeall)

local function check_config_file()
    return nixio.fs.access("/etc/config/mosdns")
end

local function prepare_content(content_type)
    luci.http.prepare_content(content_type)
end

local function write_json(data)
    luci.http.write_json(data)
end

local function write_file_content(file_path)
    luci.http.write(luci.sys.exec("cat " .. file_path))
end

local function clear_file_content(file_path)
    luci.sys.call("true > " .. file_path)
end

local function is_mosdns_running()
    return luci.sys.call("pgrep -f mosdns >/dev/null") == 0
end

function index()
    if not check_config_file() then
        return
    end

    local mosdns_page = entry(
        {"admin", "services", "mosdns"},
        alias("admin", "services", "mosdns", "basic"),
        _("MosDNS"),
        30
    )
    mosdns_page.dependent = true
    mosdns_page.acl_depends = { "luci-app-mosdns" }

    entry(
        {"admin", "services", "mosdns", "basic"},
        cbi("mosdns/basic"),
        _("Basic Setting"),
        1
    ).leaf = true

    entry(
        {"admin", "services", "mosdns", "rule_list"},
        cbi("mosdns/rule_list"),
        _("Rule List"),
        2
    ).leaf = true

    entry(
        {"admin", "services", "mosdns", "update"},
        cbi("mosdns/update"),
        _("Geodata Update"),
        3
    ).leaf = true

    entry(
        {"admin", "services", "mosdns", "log"},
        cbi("mosdns/log"),
        _("Logs"),
        4
    ).leaf = true

    entry(
        {"admin", "services", "mosdns", "status"},
        call("act_status")
    ).leaf = true

    entry(
        {"admin", "services", "mosdns", "get_log"},
        call("get_log")
    ).leaf = true

    entry(
        {"admin", "services", "mosdns", "clear_log"},
        call("clear_log")
    ).leaf = true
end

function act_status()
    local status = {
        running = is_mosdns_running()
    }
    prepare_content("application/json")
    write_json(status)
end

function get_log()
    local log_file_path = luci.sys.exec("/etc/mosdns/lib.sh logfile")
    write_file_content(log_file_path)
end

function clear_log()
    local log_file_path = luci.sys.exec("/etc/mosdns/lib.sh logfile")
    clear_file_content(log_file_path)
end
