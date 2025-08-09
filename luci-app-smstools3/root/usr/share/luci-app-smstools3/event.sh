#!/bin/sh

killall smsd

# General settings
DECODE=$(uci -q get smstools3.@sms[0].decode_utf)
STORAGE=$(uci -q get smstools3.@sms[0].storage)
LOG=$(uci -q get smstools3.@sms[0].loglevel)
LED_EN=$(uci -q get smstools3.@sms[0].led_enable)

# Modems in system config
MODEMS=$(echo $(uci show smstools3 | grep -Ev '@sms|root_phone' | awk -F [.] '/enable/{split($2,a,"="); print a[1]","}') | sed 's/.$//')

if [ ! -d /root/sms ]; then
	mkdir /root/sms
	for d in checked failed incoming outgoing sent; do
		mkdir /root/sms/${d}
	done
fi

case $STORAGE in
	persistent)
		if [ -d  /var/spool/sms ]; then
			mv /var/spool/sms /var/spool/sms_tmp
			ln -s /root/sms /var/spool/sms
		fi
		;;
	temporary)
		if [ -d  /var/spool/sms_tmp ]; then
			rm -f /var/spool/sms
			mv /var/spool/sms_tmp /var/spool/sms
		fi
		;;
esac

# template config
echo -e "devices = $MODEMS"
echo -e "incoming = /var/spool/sms/incoming\noutgoing = /var/spool/sms/outgoing"
echo -e "checked = /var/spool/sms/checked\nfailed = /var/spool/sms/failed\nsent = /var/spool/sms/sent"
echo -e "receive_before_send = no\ndate_filename = 1\ndate_filename_format = %s"
echo "eventhandler = /usr/share/luci-app-smstools3/led.sh"

if [ "$DECODE" ]; then
        echo "decode_unicode_text = yes"
        echo "incoming_utf8 = yes"
fi
echo -e "receive_before_send = no\nautosplit = 3"
if [ "$LOG" ]; then
	echo "loglevel = $LOG"
fi

MODEMS=$(echo $MODEMS | tr -d ',')

for m in $MODEMS; do

	UI=$(uci -q get smstools3.${m}.ui)
	DEVICE=$(uci -q get smstools3.${m}.device)
	PIN=$(uci -q get smstools3.${m}.pin)
	INIT_=$(uci -q get smstools3.${m}.init)
	NET_CHECK=$(uci -q get smstools3.${m}.net_check)
	SIG_CHECK=$(uci -q get smstools3.${m}.sig_check)
	ENABLE=$(uci -q get smstools3.${m}.enable)

	[ "$ENABLE" = "1" ] && {
		echo ""
		echo "[${m}]"
		case $INIT_ in
        		huawei) INIT_STRING="init = AT+CPMS=\"SM\";+CNMI=2,0,0,2,1" ;;
	        	intel) INIT_STRING="init = AT+CPMS=\"SM\"" ;;
			asr) INIT_STRING="init = AT+CPMS=\"SM\",\"SM\",\"SM\"" ;;
		        *)INIT_STRING="init = AT+CPMS=\"ME\",\"ME\",\"ME\"" ;;
		esac
		echo $INIT_STRING
		echo "device = $DEVICE"
		case $SIG_CHECK in
			1) echo "signal_quality_ber_ignore = yes" ;;
		esac
		case $NET_CHECK in
			0) echo "check_network = 0" ;;
			1) echo "check_network = 1" ;;
			2) echo "check_network = 2" ;;
		esac
		if [ ! "$UI" ]; then
        		echo -e "detect_unexpected_input = no"
		fi
		echo "incoming = yes"
		case $PIN in
        		''|*[!0-9]*) logger -t luci-app-smstools3 "invalid pin" ;;
	        	*)
	        	if  [ "$(echo "$PIN" | awk '{print length}')" -lt "4" ] || [ "$(echo "$PIN" | awk '{print length}')" -gt "4" ]; then
        	        	logger -t luci-app-smstools3 "invalid pin"
	        	else
        	        	echo "pin = $PIN"
		        fi
        		;;
		esac
		echo "baudrate = 115200"
	}
done
