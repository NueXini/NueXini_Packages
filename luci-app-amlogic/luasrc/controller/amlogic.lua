module("luci.controller.amlogic", package.seeall)

local sys = require "luci.sys"
local PKG_NAME = "luci-app-amlogic"

function index()
	if not nixio.fs.access("/etc/config/amlogic") then
		return
	end

	local page = entry({ "admin", "system", "amlogic" }, alias("admin", "system", "amlogic", "info"), _("Amlogic Service"), 88)
	page.dependent = true
	page.acl_depends = { PKG_NAME }

	local platfrom = luci.sys.exec("cat /etc/flippy-openwrt-release 2>/dev/null | grep PLATFORM | awk -F'=' '{print $2}' | grep -oE '(amlogic|rockchip|allwinner|qemu)' | xargs") or "Unknown"
	local install_menu = luci.sys.exec("cat /etc/flippy-openwrt-release 2>/dev/null | grep SHOW_INSTALL_MENU | awk -F'=' '{print $2}' | grep -oE '(yes|no)' | xargs") or "Unknown"

	entry({ "admin", "system", "amlogic", "info" }, form("amlogic/amlogic_info"), _("Amlogic Service"), 1).leaf = true
	if (string.find(platfrom, "amlogic")) ~= nil or (string.find(install_menu, "yes")) ~= nil then
		entry({ "admin", "system", "amlogic", "install" }, form("amlogic/amlogic_install"), _("Install OpenWrt"), 2).leaf = true
	end
	entry({ "admin", "system", "amlogic", "upload" }, form("amlogic/amlogic_upload"), _("Manually Upload Update"), 3).leaf = true
	entry({ "admin", "system", "amlogic", "check" }, form("amlogic/amlogic_check"), _("Online Download Update"), 4).leaf = true
	entry({ "admin", "system", "amlogic", "backup" }, form("amlogic/amlogic_backup"), _("Backup Firmware Config"), 5).leaf = true
	entry({ "admin", "system", "amlogic", "backuplist" }, form("amlogic/amlogic_backuplist")).leaf = true
	if (string.find(platfrom, "qemu")) == nil then
		entry({ "admin", "system", "amlogic", "armcpu" }, cbi("amlogic/amlogic_armcpu"), _("CPU Settings"), 6).leaf = true
	end
	entry({ "admin", "system", "amlogic", "config" }, cbi("amlogic/amlogic_config"), _("Plugin Settings"), 7).leaf = true
	entry({ "admin", "system", "amlogic", "log" }, form("amlogic/amlogic_log"), _("Server Logs"), 8).leaf = true
	entry({ "admin", "system", "amlogic", "poweroff" }, form("amlogic/amlogic_poweroff"), _("PowerOff"), 9).leaf = true
	entry({ "admin", "system", "amlogic", "check_firmware" }, call("action_check_firmware"))
	entry({ "admin", "system", "amlogic", "check_plugin" }, call("action_check_plugin"))
	entry({ "admin", "system", "amlogic", "check_kernel" }, call("action_check_kernel"))
	entry({ "admin", "system", "amlogic", "refresh_log" }, call("action_refresh_log"))
	entry({ "admin", "system", "amlogic", "del_log" }, call("action_del_log"))
	entry({ "admin", "system", "amlogic", "start_model_database" }, call("action_check_model_database")).leaf = true
	entry({ "admin", "system", "amlogic", "start_check_install" }, call("action_start_check_install")).leaf = true
	entry({ "admin", "system", "amlogic", "start_check_firmware" }, call("action_start_check_firmware")).leaf = true
	entry({ "admin", "system", "amlogic", "start_check_plugin" }, call("action_start_check_plugin")).leaf = true
	entry({ "admin", "system", "amlogic", "start_check_kernel" }, call("action_start_check_kernel")).leaf = true
	entry({ "admin", "system", "amlogic", "start_check_rescue" }, call("action_start_check_rescue")).leaf = true
	entry({ "admin", "system", "amlogic", "start_check_upfiles" }, call("action_start_check_upfiles")).leaf = true
	entry({ "admin", "system", "amlogic", "start_amlogic_install" }, call("action_start_amlogic_install")).leaf = true
	entry({ "admin", "system", "amlogic", "start_amlogic_update" }, call("action_start_amlogic_update")).leaf = true
	entry({ "admin", "system", "amlogic", "start_amlogic_kernel" }, call("action_start_amlogic_kernel")).leaf = true
	entry({ "admin", "system", "amlogic", "start_amlogic_plugin" }, call("action_start_amlogic_plugin")).leaf = true
	entry({ "admin", "system", "amlogic", "start_amlogic_rescue" }, call("action_start_amlogic_rescue")).leaf = true
	entry({ "admin", "system", "amlogic", "start_snapshot_delete" }, call("action_start_snapshot_delete")).leaf = true
	entry({ "admin", "system", "amlogic", "start_snapshot_restore" }, call("action_start_snapshot_restore")).leaf = true
	entry({ "admin", "system", "amlogic", "start_snapshot_list" }, call("action_check_snapshot")).leaf = true
	entry({ "admin", "system", "amlogic", "start_openwrt_author" }, call("action_openwrt_author")).leaf = true
	entry({ "admin", "system", "amlogic", "state" }, call("action_state")).leaf = true
	entry({ "admin", "system", "amlogic", "start_poweroff" }, call("action_poweroff")).leaf = true
	entry({ "admin", "system", "amlogic", "start_switch" }, call("action_switch")).leaf = true
end

--Remove the spaces in the string
function trim(str)
	--return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
	return (string.gsub(str, "%s+", ""))
end

--Create a temporary folder
local tmp_upload_dir = luci.sys.exec("[ -d /tmp/upload ] || mkdir -p /tmp/upload >/dev/null")
local tmp_amlogic_dir = luci.sys.exec("[ -d /tmp/amlogic ] || mkdir -p /tmp/amlogic >/dev/null")

--Whether to automatically restore the firmware config
local amlogic_firmware_config = luci.sys.exec("uci get amlogic.config.amlogic_firmware_config 2>/dev/null") or "1"
if tonumber(amlogic_firmware_config) == 0 then
	update_restore_config = "no-restore"
else
	update_restore_config = "restore"
end

--Whether to automatically write to the bootLoader
local amlogic_write_bootloader = luci.sys.exec("uci get amlogic.config.amlogic_write_bootloader 2>/dev/null") or "1"
if tonumber(amlogic_write_bootloader) == 0 then
	auto_write_bootloader = "no"
else
	auto_write_bootloader = "yes"
end

--Set the file system type of the shared partition
local amlogic_shared_fstype = luci.sys.exec("uci get amlogic.config.amlogic_shared_fstype 2>/dev/null") or ""
if trim(amlogic_shared_fstype) == "" then
	auto_shared_fstype = "ext4"
else
	auto_shared_fstype = trim(amlogic_shared_fstype)
end

--Device identification
device_platfrom = luci.sys.exec("cat /etc/flippy-openwrt-release 2>/dev/null | grep PLATFORM | awk -F'=' '{print $2}' | grep -oE '(amlogic|rockchip|allwinner|qemu)' | xargs") or "Unknown"
if (string.find(device_platfrom, "rockchip")) ~= nil then
	device_install_script = ""
	device_update_script = "openwrt-update-rockchip"
	device_kernel_script = "openwrt-kernel"
elseif (string.find(device_platfrom, "allwinner")) ~= nil then
	device_install_script = "openwrt-install-allwinner"
	device_update_script = "openwrt-update-allwinner"
	device_kernel_script = "openwrt-kernel"
elseif (string.find(device_platfrom, "qemu")) ~= nil then
	device_install_script = ""
	device_update_script = "openwrt-update-kvm"
	device_kernel_script = "openwrt-kernel"
else
	device_install_script = "openwrt-install-amlogic"
	device_update_script = "openwrt-update-amlogic"
	device_kernel_script = "openwrt-kernel"
end

--General array functions
function string.split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
	if (delimiter == '') then return false end
	local pos, arr = 0, {}
	-- for each divider found
	for st, sp in function() return string.find(input, delimiter, pos, true) end do
		table.insert(arr, string.sub(input, pos, st - 1))
		pos = sp + 1
	end
	table.insert(arr, string.sub(input, pos))
	return arr
end

--Refresh the log
function action_refresh_log()
	local logfile = "/tmp/amlogic/amlogic.log"
	if not nixio.fs.access(logfile) then
		luci.sys.exec("uname -a > /tmp/amlogic/amlogic.log && sync")
		luci.sys.exec("echo '' > /tmp/amlogic/amlogic_check_install.log && sync >/dev/null 2>&1")
		luci.sys.exec("echo '' > /tmp/amlogic/amlogic_check_upfiles.log && sync >/dev/null 2>&1")
		luci.sys.exec("echo '' > /tmp/amlogic/amlogic_check_plugin.log && sync >/dev/null 2>&1")
		luci.sys.exec("echo '' > /tmp/amlogic/amlogic_check_kernel.log && sync >/dev/null 2>&1")
		luci.sys.exec("echo '' > /tmp/amlogic/amlogic_check_firmware.log && sync >/dev/null 2>&1")
		luci.sys.exec("echo '' > /tmp/amlogic/amlogic_check_rescue.log && sync >/dev/null 2>&1")
		luci.sys.exec("echo '' > /tmp/amlogic/amlogic_running_script.log && sync >/dev/null 2>&1")
	end
	luci.http.prepare_content("text/plain; charset=utf-8")
	local f = io.open(logfile, "r+")
	f:seek("set")
	local a = f:read(2048000) or ""
	f:close()
	luci.http.write(a)
end

--Delete the logs
function action_del_log()
	luci.sys.exec(": > /tmp/amlogic/amlogic.log")
	luci.sys.exec(": > /tmp/amlogic/amlogic_check_install.log")
	luci.sys.exec(": > /tmp/amlogic/amlogic_check_upfiles.log")
	luci.sys.exec(": > /tmp/amlogic/amlogic_check_plugin.log")
	luci.sys.exec(": > /tmp/amlogic/amlogic_check_kernel.log")
	luci.sys.exec(": > /tmp/amlogic/amlogic_check_firmware.log")
	luci.sys.exec(": > /tmp/amlogic/amlogic_check_rescue.log")
	luci.sys.exec(": > /tmp/amlogic/amlogic_running_script.log")
end


--Upgrade luci-app-amlogic plugin
function start_amlogic_plugin()
	local log_file = "/tmp/amlogic/amlogic_check_plugin.log"
	local running_lock = "/tmp/amlogic/amlogic_running_script.log"
	local config_file = "/etc/config/amlogic"
	local config_bak = "/etc/config/amlogic_bak"

	-- 1. Create a running lock and clear previous log
	luci.sys.call("echo '1@Plugin update in progress, try again later!' > " .. running_lock .. " && > " .. log_file)

	-- 2. Backup config file
	luci.sys.call(string.format("[ -f %s ] && cp -vf %s %s >> %s 2>&1", config_file, config_file, config_bak, log_file))

	-- 3. Detect and install
	local install_status = 1
	if luci.sys.call("command -v opkg >/dev/null") == 0 then
		luci.sys.call("echo 'System uses opkg. Attempting to install .ipk package...' >> " .. log_file)
		local install_cmd = string.format("opkg --force-reinstall install /tmp/amlogic/*.ipk >> %s 2>&1", log_file)
		install_status = luci.sys.call(install_cmd)
	elseif luci.sys.call("command -v apk >/dev/null") == 0 then
		luci.sys.call("echo 'System uses apk. Attempting to install .apk package...' >> " .. log_file)
		local install_cmd = string.format("apk add --force-overwrite --allow-untrusted /tmp/amlogic/*.apk >> %s 2>&1", log_file)
		install_status = luci.sys.call(install_cmd)
	else
		luci.sys.call("echo 'Error: Neither opkg nor apk found. Aborting.' >> " .. log_file)
	end

	-- 4. Check result and finalize
	if install_status == 0 then
		-- SUCCESS
		luci.sys.call("echo 'Installation successful. Finalizing...' >> " .. log_file)
		luci.sys.call(string.format("[ -f %s ] && cp -vf %s %s >> %s 2>&1", config_bak, config_bak, config_file, log_file))
		luci.sys.call("rm -rf /tmp/luci-indexcache /tmp/luci-modulecache/* " .. config_bak)
		luci.sys.call("echo '' > " .. running_lock)
		luci.sys.call("echo 'Successful Update' > " .. log_file)
		return 0
	else
		-- FAILURE
		luci.sys.call("echo '--- INSTALLATION FAILED! ---' >> " .. log_file)
		luci.sys.call("echo 'Restoring configuration and aborting.' >> " .. log_file)
		luci.sys.call(string.format("[ -f %s ] && cp -vf %s %s >> %s 2>&1", config_bak, config_bak, config_file, log_file))
		luci.sys.call("rm -f " .. config_bak)
		luci.sys.call("echo '' > " .. running_lock)
		return install_status
	end
end

--Upgrade the kernel
function start_amlogic_kernel()
	luci.sys.call("echo '2@Kernel update in progress, try again later!' > /tmp/amlogic/amlogic_running_script.log && sync >/dev/null 2>&1")
	luci.sys.call("chmod +x /usr/sbin/" .. device_kernel_script .. " >/dev/null 2>&1")
	local state = luci.sys.call("/usr/sbin/" .. device_kernel_script .. " " .. auto_write_bootloader .. " > /tmp/amlogic/amlogic_check_kernel.log && sync >/dev/null 2>&1")
	return state
end

--Upgrade amlogic openwrt firmware
function start_amlogic_update()
	luci.sys.call("echo '3@OpenWrt update in progress, try again later!' > /tmp/amlogic/amlogic_running_script.log && sync >/dev/null 2>&1")
	luci.sys.call("chmod +x /usr/sbin/" .. device_update_script .. " >/dev/null 2>&1")
	local amlogic_update_sel = luci.http.formvalue("amlogic_update_sel")
	local res = string.split(amlogic_update_sel, "@")
	local update_firmware_name = res[1] or "auto"
	local update_firmware_updated = res[2] or "updated"
	local update_write_path = res[3] or "/tmp"
	luci.sys.call("echo " .. update_firmware_updated .. " > " .. update_write_path .. "/.luci-app-amlogic/op_release_code 2>/dev/null && sync")
	local state = luci.sys.call("/usr/sbin/" .. device_update_script .. " " .. update_firmware_name .. " " .. auto_write_bootloader .. " " .. update_restore_config .. " > /tmp/amlogic/amlogic_check_firmware.log && sync 2>/dev/null")
	return state
end

--Read rescue kernel log
local function start_amlogic_rescue()
	luci.sys.call("echo '4@Kernel rescue in progress, try again later!' > /tmp/amlogic/amlogic_running_script.log && sync >/dev/null 2>&1")
	luci.sys.call("chmod +x /usr/sbin/" .. device_kernel_script .. " >/dev/null 2>&1")
	local state = luci.sys.call("/usr/sbin/" .. device_kernel_script .. " -s > /tmp/amlogic/amlogic_check_rescue.log && sync >/dev/null 2>&1")
	luci.sys.call("echo '' > /tmp/amlogic/amlogic_running_script.log && sync >/dev/null 2>&1")
	return state
end

--Install amlogic openwrt firmware
function start_amlogic_install()
	luci.sys.exec("chmod +x /usr/sbin/" .. device_install_script .. " >/dev/null 2>&1")
	local amlogic_install_sel = luci.http.formvalue("amlogic_install_sel")
	local res = string.split(amlogic_install_sel, "@")
	soc_id = res[1] or "99"
	if tonumber(res[1]) == 99 then
		dtb_filename = res[2] or "auto_dtb"
	else
		dtb_filename = "auto_dtb"
	end
	local state = luci.sys.call("/usr/sbin/" .. device_install_script .. " " .. auto_write_bootloader .. " " .. soc_id .. " " .. dtb_filename .. " " .. auto_shared_fstype .. " > /tmp/amlogic/amlogic_check_install.log && sync 2>/dev/null")
	return state
end

--Delets the snapshot
function start_snapshot_delete()
	local snapshot_delete_sel = luci.http.formvalue("snapshot_delete_sel")
	local state = luci.sys.exec("btrfs subvolume delete -c /.snapshots/" .. snapshot_delete_sel .. " 2>/dev/null && sync")
	return state
end

--Restore to this snapshot
function start_snapshot_restore()
	local snapshot_restore_sel = luci.http.formvalue("snapshot_restore_sel")
	local state = luci.sys.exec("btrfs subvolume snapshot /.snapshots/etc-" .. snapshot_restore_sel .. " /etc 2>/dev/null && sync")
	local state_nowreboot = luci.sys.exec("echo 'b' > /proc/sysrq-trigger 2>/dev/null")
	return state
end

--Check the plugin
function action_check_plugin()
	luci.sys.exec("chmod +x /usr/share/amlogic/amlogic_check_plugin.sh >/dev/null 2>&1")
	return luci.sys.call("/usr/share/amlogic/amlogic_check_plugin.sh >/dev/null 2>&1")
end

--Check and download the kernel
function check_kernel()
	luci.sys.exec("chmod +x /usr/share/amlogic/amlogic_check_kernel.sh >/dev/null 2>&1")
	local kernel_options = luci.http.formvalue("kernel_options")
	if kernel_options == "check" then
		local state = luci.sys.call("/usr/share/amlogic/amlogic_check_kernel.sh -check >/dev/null 2>&1")
	else
		local state = luci.sys.call("/usr/share/amlogic/amlogic_check_kernel.sh -download " .. kernel_options .. " >/dev/null 2>&1")
	end
	return state
end

--Check the kernel
function action_check_kernel()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		check_kernel_status = check_kernel();
	})
end

--Check the firmware
function check_firmware()
	luci.sys.exec("chmod +x /usr/share/amlogic/amlogic_check_firmware.sh >/dev/null 2>&1")
	local firmware_options = luci.http.formvalue("firmware_options")
	if firmware_options == "check" then
		local state = luci.sys.call("/usr/share/amlogic/amlogic_check_firmware.sh -check >/dev/null 2>&1")
	else
		local state = luci.sys.call("/usr/share/amlogic/amlogic_check_firmware.sh -download " .. firmware_options .. " >/dev/null 2>&1")
	end
	return state
end

--Check the openwrt firmware version online
function action_check_firmware()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		check_firmware_status = check_firmware();
	})
end

--Read upload files log
local function start_check_upfiles()
	return luci.sys.exec("sed -n '$p' /tmp/amlogic/amlogic_check_upfiles.log 2>/dev/null")
end

--Read plug-in check log
local function start_check_plugin()
	return luci.sys.exec("sed -n '$p' /tmp/amlogic/amlogic_check_plugin.log 2>/dev/null")
end

--Read kernel check log
local function start_check_kernel()
	return luci.sys.exec("sed -n '$p' /tmp/amlogic/amlogic_check_kernel.log 2>/dev/null")
end

--Read openwrt firmware check log
local function start_check_firmware()
	return luci.sys.exec("sed -n '$p' /tmp/amlogic/amlogic_check_firmware.log 2>/dev/null")
end

--Read rescue kernel log
local function start_check_rescue()
	return luci.sys.exec("sed -n '$p' /tmp/amlogic/amlogic_check_rescue.log 2>/dev/null")
end

--Read openwrt install log
local function start_check_install()
	return luci.sys.exec("sed -n '$p' /tmp/amlogic/amlogic_check_install.log 2>/dev/null")
end

--Return online check plugin result
function action_start_check_plugin()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		start_check_plugin = start_check_plugin();
	})
end

--Return online check kernel result
function action_start_check_kernel()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		start_check_kernel = start_check_kernel();
	})
end

--Return online check openwrt firmware result
function action_start_check_firmware()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		start_check_firmware = start_check_firmware();
	})
end

--Return online check rescue kernel result
function action_start_check_rescue()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		start_check_rescue = start_check_rescue();
	})
end

--Return online install openwrt result
function action_start_check_install()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		start_check_install = start_check_install();
	})
end

--Return online install openwrt result for amlogic
function action_start_amlogic_install()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		rule_install_status = start_amlogic_install();
	})
end

--Return snapshot delete result
function action_start_snapshot_delete()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		rule_delete_status = start_snapshot_delete();
	})
end

--Return snapshot restore result
function action_start_snapshot_restore()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		rule_restore_status = start_snapshot_restore();
	})
end

--Return openwrt update result for amlogic
function action_start_amlogic_update()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		rule_update_status = start_amlogic_update();
	})
end

--Return kernel update result
function action_start_amlogic_kernel()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		rule_kernel_status = start_amlogic_kernel();
	})
end

--Return plugin update result
function action_start_amlogic_plugin()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		rule_plugin_status = start_amlogic_plugin();
	})
end

--Return rescue kernel result
function action_start_amlogic_rescue()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		start_amlogic_rescue = start_amlogic_rescue();
	})
end

--Return files upload result
function action_start_check_upfiles()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		start_check_upfiles = start_check_upfiles();
	})
end

--Return the current openwrt firmware version
local function current_firmware_version()
	return luci.sys.exec("uname -r 2>/dev/null | grep -oE '^[1-9].[0-9]{1,3}.[0-9]+'") or "Invalid value."
end

--Return the current plugin version
local function current_plugin_version()
    local version_str = ""

    -- Check if opkg command exists
    if sys.call("command -v opkg >/dev/null") == 0 then
        local opkg_cmd = string.format("opkg list-installed | grep '^%s' | awk '{print $3}' | cut -d'-' -f1", PKG_NAME)
        version_str = trim(sys.exec(opkg_cmd))
    end

    -- If opkg failed or not found, check if apk command exists
    if version_str == "" and sys.call("command -v apk >/dev/null") == 0 then
        local apk_cmd = string.format("apk list --installed 2>/dev/null | grep '^%s' | awk '{print $1}' | cut -d'-' -f4", PKG_NAME)
        version_str = trim(sys.exec(apk_cmd))
    end

    if version_str ~= "" then
        return version_str
    else
        return "Invalid value."
    end
end

--Return the current kernel version
local function current_kernel_version()
	return luci.sys.exec("uname -r 2>/dev/null | grep -oE '^[1-9].[0-9]{1,3}.[0-9]+'") or "Invalid value."
end

--Return the current kernel branch
local function current_kernel_branch()
	local default_kernel_branch = luci.sys.exec("uname -r 2>/dev/null | grep -oE '^[1-9].[0-9]{1,3}'")
	local amlogic_kernel_branch = luci.sys.exec("uci get amlogic.config.amlogic_kernel_branch 2>/dev/null | grep -oE '^[1-9].[0-9]{1,3}'") or ""
	if trim(amlogic_kernel_branch) == "" then
		return default_kernel_branch
	else
		return amlogic_kernel_branch
	end
end

--Return current version information
function action_state()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		current_firmware_version = current_firmware_version(),
		current_plugin_version = current_plugin_version(),
		current_kernel_version = current_kernel_version(),
		current_kernel_branch = current_kernel_branch();
	})
end

--Read external model database
local function my_model_database()
	if (string.find(device_platfrom, "allwinner")) ~= nil then
		return luci.sys.exec("cat /etc/model_database.txt 2>/dev/null | grep -E '^w[0-9]{1,9}.*:' | awk -F ':' '{print $1,$2}' OFS='###' ORS='@@@' | tr ' ' '~' 2>&1")
	else
		return luci.sys.exec("cat /etc/model_database.txt 2>/dev/null | grep -E '^[0-9]{1,9}.*:' | awk -F ':' '{print $1,$2}' OFS='###' ORS='@@@' | tr ' ' '~' 2>&1")
	end
end

--Return external model database
function action_check_model_database()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		my_model_database = my_model_database();
	})
end

--Return the current snapshot list
local function current_snapshot()
	return luci.sys.exec("btrfs subvolume list -rt / | awk '{print $4}' | grep .snapshots") or "Invalid value."
end

--Return current snapshot information
function action_check_snapshot()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		current_snapshot = current_snapshot();
	})
end

--Return the openwrt compile author
local function openwrt_author()
	return luci.sys.exec("uci get amlogic.config.amlogic_firmware_repo 2>/dev/null") or "Invalid value."
end

--Return current snapshot information
function action_openwrt_author()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		openwrt_author = openwrt_author();
	})
end

--Shut down the router
function action_poweroff()
	luci.sys.exec("/sbin/poweroff")
end

--Switching dual partition
function action_switch()
	luci.sys.exec("[ -f /boot/efi/EFI/BOOT/grub.cfg.prev ] && (cd /boot/efi/EFI/BOOT/ && mv -f grub.cfg grub.cfg.bak && mv -f grub.cfg.prev grub.cfg && mv -f grub.cfg.bak grub.cfg.prev)")
	luci.sys.exec("sync && reboot")
end

