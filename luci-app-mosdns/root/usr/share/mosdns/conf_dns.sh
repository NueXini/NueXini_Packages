#!/bin/bash
# shellcheck source=/dev/null
source /usr/share/mosdns/mosdns.sh

if is_uci_config_exists ssrp; then
  if [ "$1" = "unset" ]; then
    uci set shadowsocksr.@global[0].pdnsd_enable='1'
    uci set shadowsocksr.@global[0].tunnel_forward="$WAN_DNS0:53"
  elif [ "$1" = "" ]; then
    if [ "$(uci -q get mosdns.mosdns.listen_port)" = "5335" ]; then
      uci set shadowsocksr.@global[0].pdnsd_enable='0'
      uci del shadowsocksr.@global[0].tunnel_forward
      uci del shadowsocksr.@global[0].adblock_url
    else
      uci set shadowsocksr.@global[0].pdnsd_enable='1'
      uci set shadowsocksr.@global[0].tunnel_forward="127.0.0.1:$(uci -q get mosdns.mosdns.listen_port)"
    fi
  fi
  uci commit shadowsocksr
  [ "$(pid ssrplus)" ] && /etc/init.d/shadowsocksr restart
fi

if is_uci_config_exists pw; then
  if [ "$1" = "unset" ]; then
    uci set passwall.@global[0].dns_mode='dns2tcp'
    uci set passwall.@global[0].dns_forward="$WAN_DNS1"
    uci set passwall.@global[0].remote_dns="$WAN_DNS1"
    uci set passwall.@global[0].dns_cache='1'
    uci set passwall.@global[0].chinadns_ng='1'
  elif [ "$1" = "" ]; then
    uci set passwall.@global[0].dns_mode='udp'
    uci set passwall.@global[0].dns_forward="127.0.0.1:$(uci -q get mosdns.mosdns.listen_port)"
    uci set passwall.@global[0].remote_dns="127.0.0.1:$(uci -q get mosdns.mosdns.listen_port)"
    uci del passwall.@global[0].dns_cache
    uci del passwall.@global[0].chinadns_ng
  fi
  uci commit passwall
  [ "$(pid passwall)" ] && /etc/init.d/passwall restart
fi

if is_uci_config_exists pw2; then
  if [ "$1" = "unset" ]; then
    uci set passwall2.@global[0].direct_dns_protocol='auto'
    uci del passwall2.@global[0].direct_dns
    uci set passwall2.@global[0].remote_dns="$WAN_DNS0"
    uci set passwall2.@global[0].dns_query_strategy='UseIPv4'
  elif [ "$1" = "" ]; then
    uci set passwall2.@global[0].direct_dns_protocol='udp'
    uci set passwall2.@global[0].direct_dns="127.0.0.1:$(uci -q get mosdns.mosdns.listen_port)"
    uci set passwall2.@global[0].remote_dns_protocol='udp'
    uci set passwall2.@global[0].remote_dns="127.0.0.1:$(uci -q get mosdns.mosdns.listen_port)"
    uci set passwall2.@global[0].dns_query_strategy='UseIP'
  fi
  uci commit passwall2
  [ "$(pid passwall2)" ] && /etc/init.d/passwall2 restart
fi

if is_uci_config_exists vssr; then
  if [ "$1" = "unset" ]; then
    uci set vssr.@global[0].pdnsd_enable='1'
  elif [ "$1" = "" ]; then
    uci set vssr.@global[0].pdnsd_enable='0'
  fi
  uci commit vssr
  [ "$(pid vssr)" ] && /etc/init.d/vssr restart
fi

exit 0
