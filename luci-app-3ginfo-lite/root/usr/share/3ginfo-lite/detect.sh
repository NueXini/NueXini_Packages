#!/bin/sh

#
# (c) 2023-2024 Cezary Jackiewicz <cezary@eko.one.pl>
#
# (c) 2023-2024 modified by Rafał Wabik - IceG - From eko.one.pl forum
#


#
# from config modemdefine
#
CONFIG=modemdefine
MODEMZ=$(uci show $CONFIG | grep -o "@modemdefine\[[0-9]*\]\.modem" | wc -l | xargs)
if [ -n "$MODEMZ" ]; then

	if [[ $MODEMZ = 0 ]]; then
    		DEVICE=$(uci -q get 3ginfo.@3ginfo[0].device)
		if [ -n "$DEVICE" ]; then
			echo $DEVICE
			exit 0
		fi
    	fi

	if [[ $MODEMZ = 1 ]]; then
    		DEVICE=$(uci -q get modemdefine.@modemdefine[0].comm_port)
		if [ -n "$DEVICE" ]; then
			echo $DEVICE
			exit 0
		fi
	fi

	if [[ $MODEMZ > 1 ]]; then
		DEVICE=$(uci -q get modemdefine.@general[0].main_modem)
		if [ -n "$DEVICE" ]; then
			echo $DEVICE
			exit 0
		fi
	fi
fi


getdevicepath() {
	devname="$(basename $1)"
	case "$devname" in
	'wwan'*'at'*)
		devpath="$(readlink -f /sys/class/wwan/$devname/device)"
		echo ${devpath%/*/*/*}
		;;
	'ttyACM'*)
		devpath="$(readlink -f /sys/class/tty/$devname/device)"
		echo ${devpath%/*}
		;;
	'tty'*)
		devpath="$(readlink -f /sys/class/tty/$devname/device)"
		echo ${devpath%/*/*}
		;;
	*)
		devpath="$(readlink -f /sys/class/usbmisc/$devname/device)"
		echo ${devpath%/*}
		;;
	esac
}

# from config
DEVICE=$(uci -q get 3ginfo.@3ginfo[0].device)
if [ -n "$DEVICE" ]; then
	echo $DEVICE
	exit 0
fi

# from temporary config
MODEMFILE=/tmp/modem
touch $MODEMFILE
DEVICE=$(cat $MODEMFILE)
if [ -n "$DEVICE" ]; then
	echo $DEVICE
	exit 0
fi

# find any device
DEVICES=$(find /dev -name "ttyUSB*" -o -name "ttyACM*" -o -name "wwan*at*" | sort -r)
# limit to devices from the modem
WAN=$(uci -q get network.wan.device)
if [ -e "$WAN" ]; then
	DEVPATH=$(getdevicepath "$WAN")
	DEVICESFOUND=""
	for DEVICE in $DEVICES; do
		T=$(getdevicepath $DEVICE)
		[ "x$T" = "x$DEVPATH" ] && DEVICESFOUND="$DEVICESFOUND $DEVICE"
	done
	DEVICES="$DEVICESFOUND"
fi

for DEVICE in $DEVICES; do
	gcom -d $DEVICE -s /usr/share/3ginfo-lite/check.gcom >/dev/null 2>&1
	if [ $? = 0 ]; then
		echo "$DEVICE" | tee $MODEMFILE
		exit 0
	fi
done

echo ""
exit 0
