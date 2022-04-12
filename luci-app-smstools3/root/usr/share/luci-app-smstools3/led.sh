#!/bin/sh

LED_EN=$(uci -q get smstools3.@sms[0].led_enable)
LED=$(uci -q get smstools3.@sms[0].led)

case $1 in
	off) 
		if [ $LED_EN ]; then
			echo none > /sys/class/leds/${LED}/trigger
		fi
	;;
	RECEIVED) 
		if [ $LED_EN ]; then
			echo timer > /sys/class/leds/${LED}/trigger 
		fi
	;;
esac

if [ -r /etc/smstools3.user ]; then
	. /etc/smstools3.user
fi

NUM=$(ls -1 /var/spool/sms/incoming/ | wc -l)
BODY=$(echo $2 | awk -F [\/] '{print $NF}')

if [ $NUM -ge 100 ] && [ $NUM -lt 1000 ]; then
	NUM=0$NUM
elif [ $NUM -ge 10 ] && [ $NUM -lt 100 ]; then
        NUM=00$NUM
elif [ $NUM -ge 0 ] && [ $NUM -lt 10 ]; then
        NUM=000$NUM
fi


case $1 in
        RECEIVED) 
		mv $2 /var/spool/sms/incoming/${NUM}_${BODY}
		rm -f /var/spool/sms/incoming/*concat*
		;;
esac
