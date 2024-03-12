#!/bin/bash -e
set -o pipefail
source /etc/mosdns/lib.sh

cleanup_tmpdir() {
  [ -d "$1" ] && rm -rf "$1"
}

TMPDIR=$(mktemp -d) || exit 1

getdat geosite_cn.txt
getdat geosite_no_cn.txt
getdat geoip_cn.txt

if [ "$(grep -o cn "$TMPDIR"/geosite_cn.txt | wc -l)" -lt 100 ]; then
  cleanup_tmpdir "$TMPDIR"/geosite_cn.txt
fi

if [ "$(grep -o google "$TMPDIR"/geosite_no_cn.txt | wc -l)" -eq 0 ]; then
  cleanup_tmpdir "$TMPDIR"/geosite_no_cn.txt
fi

cp -rf "$TMPDIR"/* /etc/mosdns/rule
cleanup_tmpdir "$TMPDIR"

syncconfig=$(uci -q get mosdns.mosdns.syncconfig)
if [ "$syncconfig" -eq 1 ]; then
  TMPDIR=$(mktemp -d) || exit 2
  getdat def_config_v5.yaml

  if [ "$(grep -o plugin "$TMPDIR"/def_config_v5.yaml | wc -l)" -eq 0 ]; then
    cleanup_tmpdir "$TMPDIR"/def_config_v5.yaml
  else
    mv "$TMPDIR"/def_config_v5.yaml "$TMPDIR"/def_config_orig.yaml
  fi

  cp -rf "$TMPDIR"/* /etc/mosdns
  cleanup_tmpdir "$TMPDIR"
fi

adblock=$(uci -q get mosdns.mosdns.adblock)
if [ "$adblock" -eq 1 ]; then
  TMPDIR=$(mktemp -d) || exit 3
  getdat serverlist.txt

  if [ "$(grep -o .com "$TMPDIR"/serverlist.txt | wc -l)" -lt 1000 ]; then
    cleanup_tmpdir "$TMPDIR"/serverlist.txt
  fi

  cp -rf "$TMPDIR"/* /etc/mosdns/rule
  cleanup_tmpdir /etc/mosdns/rule/serverlist.bak
  cleanup_tmpdir "$TMPDIR"
fi

exit 0