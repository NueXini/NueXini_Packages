#!/bin/bash
# shellcheck disable=SC2034

# DNS服务器地址
LAN_DNS0="119.29.29.29"
LAN_DNS1="101.226.4.6"
WAN_DNS0="8.8.4.4"
WAN_DNS1="8.8.8.8"

# 仓库URL和代理URL
REPO_URL="https://cdn.jsdelivr.net/gh/QiuSimons/openwrt-mos@master/dat"
PROXY_URL=""

# 获取代理URL
get_proxy_url() {
  local proxy_url
  proxy_url=$(uci -q get mosdns.mosdns.proxy_url)
  PROXY_URL="${proxy_url:-https://gh.404delivr.workers.dev}"
}

# 获取日志文件路径
get_logfile_path() {
  local config_file
  local log_file=""
  config_file=$(uci -q get mosdns.mosdns.configfile)
  if [ "$config_file" = "./def_config.yaml" ]; then
    log_file=$(uci -q get mosdns.mosdns.logfile)
  else
    if [ ! -f /etc/mosdns/cus_config.yaml ]; then
      exit 1
    fi
    log_file=$(awk '/^log:/{f=1;next}f=1{if($0~/file:/){print;exit}if($0~/^[^ ]/)exit}' /etc/mosdns/cus_config.yaml | grep -Eo "/[^'\"]+")
  fi
  echo "$log_file"
}

# 检查命令是否存在
is_command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# 检查UCI配置是否存在
is_uci_config_exists() {
  local config="$1"
  case "$config" in
  ssrp) uci get shadowsocksr.@global[0].global_server &>/dev/null ;;
  pw) uci get passwall.@global[0].enabled &>/dev/null ;;
  pw2) uci get passwall2.@global[0].enabled &>/dev/null ;;
  vssr) uci get vssr.@global[0].global_server &>/dev/null ;;
  esac
}

# 获取备用DNS服务器地址
get_backup_dns() {
  local index="$1"
  case "$index" in
  0) echo "$LAN_DNS0" ;;
  1) echo "$LAN_DNS1" ;;
  esac
}

# 下载文件
download_file() {
  local url="$1"
  local filename="$2"
  if is_command_exists curl; then
    curl -fSLo "$filename" "$url"
  else
    wget "$url" --no-check-certificate -O "$filename"
  fi
}

# 获取DNS服务器地址
get_dns_server() {
  local index="$1"
  local status="$2"
  local dns_server=""
  if [ "$status" = "inactive" ]; then
    dns_server=$(ubus call network.interface.wan status | jsonfilter -e "@['inactive']['dns-server'][$index]")
  else
    dns_server=$(ubus call network.interface.wan status | jsonfilter -e "@['dns-server'][$index]")
  fi
  echo "$dns_server"
}

# 获取进程ID
get_process_id() {
  pgrep -f "$1"
}

# 清理临时目录
cleanup_directory() {
  local dir="$1"
  if [ -d "$dir" ]; then
    rm -rf "$dir"
  fi
}

# 更新MosDNS
update_mosdns() {
  local temp_dir
  local sync_config
  local ad_block
  local data_prefix="${REPO_URL}"
  temp_dir=$(mktemp -d) || exit 1
  sync_config=$(uci -q get mosdns.mosdns.sync_config)
  ad_block=$(uci -q get mosdns.mosdns.ad_block)
  local files=(
    "geosite_cn.txt"
    "geosite_no_cn.txt"
    "geoip_cn.txt"
  )

  if [ "$ad_block" = "1" ]; then
    files+=("serverlist.txt")
  fi

  for file in "${files[@]}"; do
    download_file "${data_prefix}/${file}" "${temp_dir}/${file}"
  done

  if [ "$sync_config" = "1" ]; then
    download_file "${data_prefix}/def_config_v5.yaml" "${temp_dir}/def_config_orig.yaml"
    cp -rf "${temp_dir}/def_config_orig.yaml" /etc/mosdns/def_config.yaml
  fi

  cp -rf "${temp_dir}"/* /etc/mosdns/rule
  cleanup_directory "$temp_dir"

  exit 0
}

# 主程序
main() {
  local command="$1"
  local arg1="$2"
  case "$command" in
  logfile)
    get_logfile_path
    ;;
  dns)
    if ! ifconfig | grep -q wan; then
      get_backup_dns "$arg1"
      exit 0
    fi
    local dns_server=""
    if [[ "$(get_dns_server 0)" =~ ^127\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      dns_server=$(get_dns_server "$arg1" "inactive")
    elif [[ "$(get_dns_server "$arg1")" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      dns_server=$(get_dns_server "$arg1")
    else
      dns_server=$(get_backup_dns "$arg1")
    fi
    echo "$dns_server"
    ;;
  update_mosdns)
    update_mosdns
    ;;
  esac
}

# 获取代理URL
get_proxy_url

# 执行主程序
main "$@"
