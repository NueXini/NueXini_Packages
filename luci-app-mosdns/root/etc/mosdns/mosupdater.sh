#!/bin/bash -e
set -o pipefail
source /etc/mosdns/lib.sh

cleanup_tmpdir() {
  [ -d "$1" ] && rm -rf "$1"
}

TMPDIR=$(mktemp -d) || exit 1
syncconfig=$(uci -q get mosdns.mosdns.syncconfig)
adblock=$(uci -q get mosdns.mosdns.adblock)

getdat geosite_cn.txt
getdat geosite_no_cn.txt
getdat geoip_cn.txt

[ "$adblock" == "1" ] && getdat serverlist.txt

if [ "$syncconfig" == "1" ]; then
  getdat def_config_v5.yaml
  mv "$TMPDIR"/def_config_v5.yaml "$TMPDIR"/def_config_orig.yaml
  cp -rf "$TMPDIR"/def_config_orig.yaml /etc/mosdns
fi

cp -rf "$TMPDIR"/* /etc/mosdns/rule
cleanup_tmpdir "$TMPDIR"

exit 0
