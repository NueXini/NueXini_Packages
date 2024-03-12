#!/bin/sh

LED_EN=$(uci -q get smstools3.@sms[0].led_enable)
LED=$(uci -q get smstools3.@sms[0].led)

case $1 in
	off) 
		if [ $LED_EN ]; then
			echo none > /sys/class/leds/${LED}/trigger 
			/etc/init.d/led restart
		fi
	;;
	RECEIVED) 
		if [ $LED_EN ]; then
			echo timer > /sys/class/leds/${LED}/trigger 
		fi
	;;
esac

if [ -r /usr/share/luci-app-smstools3/smscommand.sh ]; then
	. /usr/share/luci-app-smstools3/smscommand.sh
fi

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
	SENT)
		if sed -e '/^$/ q' < "$2" | grep "^Alphabet: UCS" > /dev/null; then
			TMPFILE=`mktemp /tmp/smsd_XXXXXX`
			sed -e '/^$/ q' < "$2" | sed -e 's/Alphabet: UCS/Alphabet: UTF-8/g' > $TMPFILE
			sed -e '1,/^$/ d' < $2 | iconv -f UNICODEBIG -t UTF-8 >> $TMPFILE
			mv -f $TMPFILE $2
		fi
	;;
esac
