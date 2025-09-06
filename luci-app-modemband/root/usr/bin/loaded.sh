#!/bin/sh

#
# Copyright 2022-2025 Rafał Wabik (IceG) - From eko.one.pl forum
#
# MIT License
#

RES="/usr/share/modemband"

# modem type
getmodem() {

MDM=$(uci -q get modemband.@modemband[0].modemid)

if [ "${MDM}" == "" ]; then

_DEVS=$(awk '{gsub("="," ");
if ($0 ~ /Bus.*Lev.*Prnt.*Port.*/) {T=$0}
if ($0 ~ /Vendor.*ProdID/) {idvendor[T]=$3; idproduct[T]=$5}
if ($0 ~ /Product/) {product[T]=$3}}
END {for (idx in idvendor) {printf "%s%s\n%s%s%s\n", idvendor[idx], idproduct[idx], idvendor[idx], idproduct[idx], product[idx]}}' /sys/kernel/debug/usb/devices)
	for _DEV in $_DEVS; do
		if [ -e "$RES/$_DEV" ]; then
			echo "$_DEV"
			break
		fi
	done

else
  	echo "$MDM"
fi
}

case $1 in
	"json")
		. /usr/share/libubox/jshn.sh
		json_init
		json_add_string modem "$(getmodem)"
		json_add_array
		json_close_array
		json_dump
		;;

esac

exit 0

