#!/bin/sh

# Copyright 2022 Rafał Wabik (IceG) - From eko.one.pl forum
# MIT License

RES="/usr/share/modemband"

# modem type
getmodem() {

_DEVS=$(awk '/Vendor=/{gsub(/.*Vendor=| ProdID=| Rev.*/,"");print}' /sys/kernel/debug/usb/devices | sort -u)
for _DEV in $_DEVS; do
	if [ -e "$RES/$_DEV" ]; then
		echo "$_DEV"
		break
	fi
done
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
