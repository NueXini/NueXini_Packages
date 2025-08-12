#!/bin/sh

#
# (c) 2010-2025 Cezary Jackiewicz <cezary@eko.one.pl>
#
# (c) 2021-2025 modified by Rafał Wabik - IceG - From eko.one.pl forum
#


band4g() {
# see https://en.wikipedia.org/wiki/LTE_frequency_bands
	echo -n "B${1}"
	case "${1}" in
		"1") echo " (2100 MHz)";;
		"2") echo " (1900 MHz)";;
		"3") echo " (1800 MHz)";;
		"4") echo " (1700 MHz)";;
		"5") echo " (850 MHz)";;
		"7") echo " (2600 MHz)";;
		"8") echo " (900 MHz)";;
		"11") echo " (1500 MHz)";;
		"12") echo " (700 MHz)";;
		"13") echo " (700 MHz)";;
		"14") echo " (700 MHz)";;
		"17") echo " (700 MHz)";;
		"18") echo " (850 MHz)";;
		"19") echo " (850 MHz)";;
		"20") echo " (800 MHz)";;
		"21") echo " (1500 MHz)";;
		"24") echo " (1600 MHz)";;
		"25") echo " (1900 MHz)";;
		"26") echo " (850 MHz)";;
		"28") echo " (700 MHz)";;
		"29") echo " (700 MHz)";;
		"30") echo " (2300 MHz)";;
		"31") echo " (450 MHz)";;
		"32") echo " (1500 MHz)";;
		"34") echo " (2000 MHz)";;
		"37") echo " (1900 MHz)";;
		"38") echo " (2600 MHz)";;
		"39") echo " (1900 MHz)";;
		"40") echo " (2300 MHz)";;
		"41") echo " (2500 MHz)";;
		"42") echo " (3500 MHz)";;
		"43") echo " (3700 MHz)";;
		"46") echo " (5200 MHz)";;
		"47") echo " (5900 MHz)";;
		"48") echo " (3500 MHz)";;
		"50") echo " (1500 MHz)";;
		"51") echo " (1500 MHz)";;
		"53") echo " (2400 MHz)";;
		"54") echo " (1600 MHz)";;
		"65") echo " (2100 MHz)";;
		"66") echo " (1700 MHz)";;
		"67") echo " (700 MHz)";;
		"69") echo " (2600 MHz)";;
		"70") echo " (1700 MHz)";;
		"71") echo " (600 MHz)";;
		"72") echo " (450 MHz)";;
		"73") echo " (450 MHz)";;
		"74") echo " (1500 MHz)";;
		"75") echo " (1500 MHz)";;
		"76") echo " (1500 MHz)";;
		"85") echo " (700 MHz)";;
		"87") echo " (410 MHz)";;
		"88") echo " (410 MHz)";;
		"103") echo " (700 MHz)";;
		"106") echo " (900 MHz)";;
		"*") echo "";;
	esac
}

band5g() {
# see https://en.wikipedia.org/wiki/5G_NR_frequency_bands
	echo -n "n${1}"
	case "${1}" in
		"1") echo " (2100 MHz)";;
		"2") echo " (1900 MHz)";;
		"3") echo " (1800 MHz)";;
		"5") echo " (850 MHz)";;
		"7") echo " (2600 MHz)";;
		"8") echo " (900 MHz)";;
		"12") echo " (700 MHz)";;
		"13") echo " (700 MHz)";;
		"14") echo " (700 MHz)";;
		"18") echo " (850 MHz)";;
		"20") echo " (800 MHz)";;
		"24") echo " (1600 MHz)";;
		"25") echo " (1900 MHz)";;
		"26") echo " (850 MHz)";;
		"28") echo " (700 MHz)";;
		"29") echo " (700 MHz)";;
		"30") echo " (2300 MHz)";;
		"34") echo " (2100 MHz)";;
		"38") echo " (2600 MHz)";;
		"39") echo " (1900 MHz)";;
		"40") echo " (2300 MHz)";;
		"41") echo " (2500 MHz)";;
		"46") echo " (5200 MHz)";;
		"47") echo " (5900 MHz)";;
		"48") echo " (3500 MHz)";;
		"50") echo " (1500 MHz)";;
		"51") echo " (1500 MHz)";;
		"53") echo " (2400 MHz)";;
		"54") echo " (1600 MHz)";;
		"65") echo " (2100 MHz)";;
		"66") echo " (1700/2100 MHz)";;
		"67") echo " (700 MHz)";;
		"70") echo " (2000 MHz)";;
		"71") echo " (600 MHz)";;
		"74") echo " (1500 MHz)";;
		"75") echo " (1500 MHz)";;
		"76") echo " (1500 MHz)";;
		"77") echo " (3700 MHz)";;
		"78") echo " (3500 MHz)";;
		"79") echo " (4700 MHz)";;
		"80") echo " (1800 MHz)";;
		"81") echo " (900 MHz)";;
		"82") echo " (800 MHz)";;
		"83") echo " (700 MHz)";;
		"84") echo " (2100 MHz)";;
		"85") echo " (700 MHz)";;
		"86") echo " (1700 MHz)";;
		"89") echo " (850 MHz)";;
		"90") echo " (2500 MHz)";;
		"91") echo " (800/1500 MHz)";;
		"92") echo " (800/1500 MHz)";;
		"93") echo " (900/1500 MHz)";;
		"94") echo " (900/1500 MHz)";;
		"95") echo " (2100 MHz)";;
		"96") echo " (6000 MHz)";;
		"97") echo " (2300 MHz)";;
		"98") echo " (1900 MHz)";;
		"99") echo " (1600 MHz)";;
		"100") echo " (900 MHz)";;
		"101") echo " (1900 MHz)";;
		"102") echo " (6200 MHz)";;
		"104") echo " (6700 MHz)";;
		"105") echo " (600 MHz)";;
		"106") echo " (900 MHz)";;
		"109") echo " (700/1500 MHz)";;
		"257") echo " (28 GHz)";;
		"258") echo " (26 GHz)";;
		"259") echo " (41 GHz)";;
		"260") echo " (39 GHz)";;
		"261") echo " (28 GHz)";;
		"262") echo " (47 GHz)";;
		"263") echo " (60 GHz)";;
		"*") echo "";;
	esac
}

getdevicevendorproduct() {
	devname="$(basename $1)"
	case "$devname" in
        'mhi_DUN'*)
            devpath=$(find /sys/devices -name "$devname" -type d 2>/dev/null | head -1)
            target_dir=${devpath%/*/*/*}
            V=$(cat "$target_dir/vendor")
            D=$(cat "$target_dir/device")
            echo "pci/${V/0x/}${D/0x/}"
	    ;; 
		'wwan'*'at'*)
			devpath="$(readlink -f /sys/class/wwan/$devname/device)"
			T=${devpath%/*/*/*}
			if [ -e $T/vendor ] && [ -e $T/device ]; then
				V=$(cat $T/vendor)
				D=$(cat $T/device)
				echo "pci/${V/0x/}${D/0x/}"
			fi
			;;
		'ttyACM'*)
			devpath="$(readlink -f /sys/class/tty/$devname/device)"
			T=${devpath%/*}
			echo "usb/$(cat $T/idVendor)$(cat $T/idProduct)"
			;;
		'tty'*)
			devpath="$(readlink -f /sys/class/tty/$devname/device)"
			T=${devpath%/*/*}
			echo "usb/$(cat $T/idVendor)$(cat $T/idProduct)"
			;;
		*)
			devpath="$(readlink -f /sys/class/usbmisc/$devname/device)"
			T=${devpath%/*}
			echo "usb/$(cat $T/idVendor)$(cat $T/idProduct)"
			;;
	esac
}

RES="/usr/share/3ginfo-lite"

DEVICE=$($RES/detect.sh)
if [ -z "$DEVICE" ]; then
	echo '{"error":"Device not found"}'
	exit 0
fi

O=""
if [ -e /usr/bin/sms_tool ]; then
	O=$(sms_tool -D -d $DEVICE at "AT+CPIN?;+CSQ;+COPS=3,0;+COPS?;+COPS=3,2;+COPS?;+CREG=2;+CREG?")
else
	O=$(gcom -d $DEVICE -s $RES/info.gcom 2>/dev/null)
fi

getpath() {
	devname="$(basename $1)"
	case "$devname" in
	'wwan'*'at'*)
		devpath="$(readlink -f /sys/class/wwan/$devname/device)"
		P=${devpath%/*/*/*}
		;;
	'ttyACM'*)
		devpath="$(readlink -f /sys/class/tty/$devname/device)"
		P=${devpath%/*}
		;;
	'tty'*)
		devpath="$(readlink -f /sys/class/tty/$devname/device)"
		P=${devpath%/*/*}
		;;
	*)
		devpath="$(readlink -f /sys/class/usbmisc/$devname/device/)"
		P=${devpath%/*}
		;;
	esac
}

# --- modemdefine - WAN config ---
CONFIG=modemdefine
MODEMZ=$(uci show $CONFIG 2>/dev/null | grep -o "@modemdefine\[[0-9]*\]\.modem" | wc -l | xargs)
if [[ $MODEMZ -gt 1 ]]; then
	SEC=$(uci -q get modemdefine.@general[0].main_network)
fi
if [[ $MODEMZ -eq 0 ]]; then
	SEC=$(uci -q get 3ginfo.@3ginfo[0].network)
fi
if [[ $MODEMZ -eq 1 ]]; then
	SEC=$(uci -q get modemdefine.@modemdefine[0].network)
fi

if [ -z "$SEC" ]; then
	getpath $DEVICE
	PORIG=$P
	for DEV in /sys/class/tty/* /sys/class/usbmisc/*; do
		getpath "/dev/"${DEV##/*/}
		if [ "x$PORIG" == "x$P" ]; then
			SEC=$(uci show network | grep "/dev/"${DEV##/*/} | cut -f2 -d.)
			[ -n "$SEC" ] && break
		fi
	done
fi
# --- modemdefine config ---

CONN_TIME="-"
RX="-"
TX="-"

NETUP=$(ifstatus $SEC | grep "\"up\": true")
if [ -n "$NETUP" ]; then

		CT=$(uci -q -P /var/state/ get network.$SEC.connect_time)
		if [ -z $CT ]; then
			CT=$(ifstatus $SEC | awk -F[:,] '/uptime/ {print $2}' | xargs)
		else
			UPTIME=$(cut -d. -f1 /proc/uptime)
			CT=$((UPTIME-CT))
		fi
		if [ ! -z $CT ]; then

			D=$(expr $CT / 60 / 60 / 24)
			H=$(expr $CT / 60 / 60 % 24)
			M=$(expr $CT / 60 % 60)
			S=$(expr $CT % 60)
			CONN_TIME=$(printf "%dd, %02d:%02d:%02d" $D $H $M $S)
			CONN_TIME_SINCE=$(date "+%Y%m%d%H%M%S" -d "@$(($(date +%s) - CT))")
			
		fi
		
		IFACE=$(ifstatus $SEC | awk -F\" '/l3_device/ {print $4}')
		if [ -n "$IFACE" ]; then
			RX=$(ifconfig $IFACE | awk -F[\(\)] '/bytes/ {printf "%s",$2}')
			TX=$(ifconfig $IFACE | awk -F[\(\)] '/bytes/ {printf "%s",$4}')
		fi
fi

# CSQ
CSQ=$(echo "$O" | awk -F[,\ ] '/^\+CSQ/ {print $2}')

[ "x$CSQ" == "x" ] && CSQ=-1
if [ $CSQ -ge 0 -a $CSQ -le 31 ]; then
	CSQ_PER=$(($CSQ * 100/31))
else
	CSQ=""
	CSQ_PER=""
fi

# COPS numeric
# see https://mcc-mnc.com/
# Update: 11/11/2024 items: 3121
COPS=""
COPS_MCC=""
COPS_MNC=""
COPS_NUM=$(echo "$O" | awk -F[\"] '/^\+COPS:\s*.,2/ {print $2}')
if [ -n "$COPS_NUM" ]; then
	COPS_MCC=${COPS_NUM:0:3}
	COPS_MNC=${COPS_NUM:3:3}
fi

TCOPS=$(echo "$O" | awk -F[\"] '/^\+COPS:\s*.,0/ {print $2}')
[ "x$TCOPS" != "x" ] && COPS="$TCOPS"

if [ -z "$COPS" ]; then
	if [ -n "$COPS_NUM" ]; then
		COPS=$(awk -F[\;] '/^'$COPS_NUM';/ {print $3}' $RES/mccmnc.dat | xargs)
		LOC=$(awk -F[\;] '/^'$COPS_NUM';/ {print $2}' $RES/mccmnc.dat)
	fi
fi
[ -z "$COPS" ] && COPS=$COPS_NUM
case "$COPS" in
    *\ *) 
        COPS=$(echo "$COPS" | awk '{if(NF==2 && tolower($1)==tolower($2)){print $1}else{print $0}}')
        ;;
esac

isp=$(sms_tool -d "$DEVICE" at "AT+COPS?" | sed -n '2p' | cut -d '"' -f2 | tr -d '\r')
isp_num="$COPS_MCC $COPS_MNC"
isp_numws="$COPS_MCC$COPS_MNC"

case "$COPS" in
    *[!0-9]* | '')
	# Non-numeric characters or is blank
        ;;
    *) 
        if [ "$COPS" = "$isp_num" ] || [ "$COPS" = "$isp_numws" ]; then
            if [ -n "$isp" ]; then
                COPS=$(awk -F[\;] '/^'"$isp"';/ {print $3}' $RES/mccmnc.dat | xargs)
                LOC=$(awk -F[\;] '/^'"$isp"';/ {print $2}' $RES/mccmnc.dat)
            fi
        fi
	;;
esac


# operator location from temporary config
LOCATIONFILE=/tmp/location
if [ -e "$LOCATIONFILE" ]; then
	touch $LOCATIONFILE
	LOC=$(cat $LOCATIONFILE)
	if [ -n "$LOC" ]; then
		LOC=$(cat $LOCATIONFILE)
			if [[ $LOC == "-" ]]; then
				rm $LOCATIONFILE
				LOC=$(awk -F[\;] '/^'$COPS_NUM';/ {print $2}' $RES/mccmnc.dat)
				if [ -n "$LOC" ]; then
					echo "$LOC" > /tmp/location
				fi
			else
				LOC=$(awk -F[\;] '/^'$COPS_NUM';/ {print $2}' $RES/mccmnc.dat)
				if [ -n "$LOC" ]; then
					echo "$LOC" > /tmp/location
				fi
			fi
	fi
else
	case "$COPS_MCC$COPS_MNC" in
    		*[!0-9]* | '')
        	# Non-numeric characters or is blank
        	;;
    		*) 
        		if [ -n "$LOC" ]; then
            			LOC=$(awk -F[\;] '/^'"$COPS_MCC$COPS_MNC"';/ {print $2}' $RES/mccmnc.dat)
            			echo "$LOC" > /tmp/location
        		else
            			echo "-" > /tmp/location
        		fi
        	;;
	esac
fi

T=$(echo "$O" | awk -F[,\ ] '/^\+CPIN:/ {print $0;exit}' | xargs)
if [ -n "$T" ]; then
	[ "$T" == "+CPIN: READY" ] || REG=$(echo "$T" | cut -f2 -d: | xargs)
fi

T=$(echo "$O" | awk -F[,\ ] '/^\+CME ERROR:/ {print $0;exit}')
if [ -n "$T" ]; then
	case "$T" in
		"+CME ERROR: 10"*) REG="SIM not inserted";;
		"+CME ERROR: 11"*) REG="SIM PIN required";;
		"+CME ERROR: 12"*) REG="SIM PUK required";;
		"+CME ERROR: 13"*) REG="SIM failure";;
		"+CME ERROR: 14"*) REG="SIM busy";;
		"+CME ERROR: 15"*) REG="SIM wrong";;
		"+CME ERROR: 17"*) REG="SIM PIN2 required";;
		"+CME ERROR: 18"*) REG="SIM PUK2 required";;
		*) REG=$(echo "$T" | cut -f2 -d: | xargs);;
	esac
fi

# CREG
eval $(echo "$O" | busybox awk -F[,] '/^\+CREG/ {gsub(/[[:space:]"]+/,"");printf "T=\"%d\";LAC_HEX=\"%X\";CID_HEX=\"%X\";LAC_DEC=\"%d\";CID_DEC=\"%d\";MODE_NUM=\"%d\"", $2, "0x"$3, "0x"$4, "0x"$3, "0x"$4, $5}')
case "$T" in
	0*) REG="0";;
	1*) REG="1";;
	2*) REG="2";;
	3*) REG="3";;
	5*) REG="5";;
	6*) REG="6";;
	7*) REG="7";;
	*) REG="";;
esac

# MODE
if [ -z "$MODE_NUM" ] || [ "x$MODE_NUM" == "x0" ]; then
#	MODE_NUM=$(echo "$O" | awk -F[,] '/^\+COPS/ {print $4;exit}' | xargs)
	MODE_NUM=$(echo "$O" | awk -F[,] '/^\+COPS: 0,2/ {print $4;exit}' | xargs)
fi
case "$MODE_NUM" in
	2*) MODE="UMTS";;
	3*) MODE="EDGE";;
	4*) MODE="HSDPA";;
	5*) MODE="HSUPA";;
	6*) MODE="HSPA";;
	7*) MODE="LTE";;
	 *) MODE="-";;
esac

# TAC
OTX=$(sms_tool -d $DEVICE at "at+cereg")
TAC=$(echo "$OTX" | awk -F[,] '/^\+CEREG/ {printf "%s", toupper($3)}' | sed 's/[^A-F0-9]//g')
if [ "x$TAC" != "x" ]; then
	TAC_HEX=$(printf %d 0x$TAC)
else
	TAC="-"
	TAC_HEX="-"
fi

CONF_DEVICE=$(uci -q get 3ginfo.@3ginfo[0].device)
if echo "x$CONF_DEVICE" | grep -q "192.168."; then
	if grep -q "Vendor=1bbb" /sys/kernel/debug/usb/devices; then
		. $RES/modem/hilink/alcatel_hilink.sh $DEVICE
	fi
	if grep -q "Vendor=12d1" /sys/kernel/debug/usb/devices; then
		. $RES/modem/hilink/huawei_hilink.sh $DEVICE
	fi
	if grep -q "Vendor=19d2" /sys/kernel/debug/usb/devices; then
		. $RES/modem/hilink/zte.sh $DEVICE
	fi
	SEC=$(uci -q get 3ginfo.@3ginfo[0].network)
	SEC=${SEC:-wan}
else

if [ -e /usr/bin/sms_tool ]; then
	REGOK=0
	[ "x$REG" == "x1" ] || [ "x$REG" == "x5" ] || [ "x$REG" == "x6" ] || [ "x$REG" == "x7" ] && REGOK=1
	VIDPID=$(getdevicevendorproduct $DEVICE)
	if [ -e "$RES/modem/$VIDPID" ]; then
		case $(cat /tmp/sysinfo/board_name) in
			"zte,mf289f")
				. "$RES/modem/usb/19d21485"
				;;
			*)
				. "$RES/modem/$VIDPID"
				;;
		esac
	fi
fi

fi

sanitize_string() {
[ -z "$1" ] && echo "-" || echo "$1" | tr -d '\r\n'
}
sanitize_number() {
[ -z "$1" ] && echo "-" || echo "$1"
}

cat <<EOF
{
"conn_time":"$(sanitize_string "$CONN_TIME")",
"conn_time_sec":"$(sanitize_number "$CT")",
"conn_time_since":"$(sanitize_string "$CONN_TIME_SINCE")",
"rx":"$(sanitize_number "$RX")",
"tx":"$(sanitize_number "$TX")",
"modem":"$(sanitize_string "$MODEL")",
"mtemp":"$(sanitize_string "$TEMP")",
"firmware":"$(sanitize_string "$FW")",
"cport":"$(sanitize_string "$DEVICE")",
"protocol":"$(sanitize_string "$PROTO")",
"csq":"$(sanitize_number "$CSQ")",
"signal":"$(sanitize_number "$CSQ_PER")",
"operator_name":"$(sanitize_string "$COPS")",
"operator_mcc":"$(sanitize_string "$COPS_MCC")",
"operator_mnc":"$(sanitize_string "$COPS_MNC")",
"location":"$(sanitize_string "$LOC")",
"mode":"$(sanitize_string "$MODE")",
"registration":"$(sanitize_string "$REG")",
"simslot":"$(sanitize_string "$SSIM")",
"imei":"$(sanitize_string "$NR_IMEI")",
"imsi":"$(sanitize_string "$NR_IMSI")",
"iccid":"$(sanitize_string "$NR_ICCID")",
"lac_dec":"$(sanitize_number "$LAC_DEC")",
"lac_hex":"$(sanitize_string "$LAC_HEX")",
"tac_dec":"$(sanitize_number "$TAC_DEC")",
"tac_hex":"$(sanitize_string "$TAC_HEX")",
"tac_h":"$(sanitize_string "$T_HEX")",
"tac_d":"$(sanitize_number "$T_DEC")",
"cid_dec":"$(sanitize_number "$CID_DEC")",
"cid_hex":"$(sanitize_string "$CID_HEX")",
"pci":"$(sanitize_number "$PCI")",
"earfcn":"$(sanitize_number "$EARFCN")",
"pband":"$(sanitize_string "$PBAND")",
"s1band":"$(sanitize_string "$S1BAND")",
"s1pci":"$(sanitize_number "$S1PCI")",
"s1earfcn":"$(sanitize_number "$S1EARFCN")",
"s2band":"$(sanitize_string "$S2BAND")",
"s2pci":"$(sanitize_number "$S2PCI")",
"s2earfcn":"$(sanitize_number "$S2EARFCN")",
"s3band":"$(sanitize_string "$S3BAND")",
"s3pci":"$(sanitize_number "$S3PCI")",
"s3earfcn":"$(sanitize_number "$S3EARFCN")",
"s4band":"$(sanitize_string "$S4BAND")",
"s4pci":"$(sanitize_number "$S4PCI")",
"s4earfcn":"$(sanitize_number "$S4EARFCN")",
"rsrp":"$(sanitize_number "$RSRP")",
"rsrq":"$(sanitize_number "$RSRQ")",
"rssi":"$(sanitize_number "$RSSI")",
"sinr":"$(sanitize_number "$SINR")"
}
EOF
exit 0

