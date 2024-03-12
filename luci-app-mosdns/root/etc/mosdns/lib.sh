#!/bin/bash

LAN_DNS0="119.29.29.29"
LAN_DNS1="101.226.4.6"
WAN_DNS0="8.8.4.4"
WAN_DNS1="8.8.8.8"
REPO_URL="https://github.com/QiuSimons/openwrt-mos/raw/master/dat"

proxy_url=$(uci -q get mosdns.mosdns.proxy_url)
if [ -z "$proxy_url" ]; then
  PROXY_URL="https://gh.404delivr.workers.dev"
else
  PROXY_URL="$proxy_url"
fi

DAT_PREFIX="$PROXY_URL/$REPO_URL"

logfile_path() {
  configfile=$(uci -q get mosdns.mosdns.configfile)
  if [ "$configfile" = "./def_config.yaml" ]; then
    uci -q get mosdns.mosdns.logfile
  else
    [ ! -f /etc/mosdns/cus_config.yaml ] && exit 1
    awk '/^log:/{f=1;next}f==1{if($0~/file:/){print;exit}if($0~/^[^ ]/)exit}' /etc/mosdns/cus_config.yaml | grep -Eo "/[^'\"]+"
  fi
}

ext() {
  command -v "$1" > /dev/null 2>&1
}

uci_ext() {
  case "$1" in
    ssrp) uci get shadowsocksr.@global[0].global_server &> /dev/null ;;
    pw) uci get passwall.@global[0].enabled &> /dev/null ;;
    pw2) uci get passwall2.@global[0].enabled &> /dev/null ;;
    vssr) uci get vssr.@global[0].global_server &> /dev/null ;;
  esac
}

bakdns() {
  case "$1" in
    0) echo "$LAN_DNS0" ;;
    1) echo "$LAN_DNS1" ;;
  esac
}

getdat() {
  if ext curl; then
    curl -fSLo "$TMPDIR/$1" "$DAT_PREFIX/$1"
  else
    wget "$DAT_PREFIX/$1" --no-check-certificate -O "$TMPDIR/$1"
  fi
}

getdns() {
  if [ "$2" == "inactive" ]; then
    ubus call network.interface.wan status | jsonfilter -e "@['inactive']['dns-server'][$1]"
  else
    ubus call network.interface.wan status | jsonfilter -e "@['dns-server'][$1]"
  fi
}

pid() {
  pgrep -f "$1"
}

if [ "$1" == "logfile" ]; then
  logfile_path
elif [[ "$1" == "dns" && "$2" -le 1 ]]; then
  if [ "$(ifconfig | grep -c wan)" = 0 ]; then
    bakdns "$2"
    exit 0
  fi
  if [[ "$(getdns 0)" =~ ^127\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    getdns "$2" inactive
  elif [[ "$(getdns "$2")" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    getdns "$2"
  else
    bakdns "$2"
  fi
fi
