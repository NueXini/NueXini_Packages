#!/bin/sh

TO="timeout"
which timeout >/dev/null 2>&1 && timeout -t1 pwd >/dev/null 2>&1 && TO="timeout -t"

cd /tmp

_NAME=`basename $0`
PID=$$
LOCKDIR=/tmp/$_NAME.lck

cleanup () {
	if rm -rf $LOCKDIR; then
		echo "Finished"
	else
		echo "Failed to remove lock directory '$LOCKDIR'"
		return 1
	fi
}

ping_cli() {
	PING="ping"
	which timeout >/dev/null 2>&1 && PING="$TO 30 $PING"
	while :; do
		test -f $LOCKDIR/$PID || return 0
		PINGH=ec3ns.ptpt52.com
		if [ "$(echo $PINGH | wc -w)" = "1" ]; then
			$PING -t1 -s30 -c30 -W1 -q $PINGH
			sleep 1
		else
			for hh in $PINGH; do
				$PING -t1 -s30 -c30 -W1 -q "$hh" &
			done
			sleep 32
		fi
	done
}

if mkdir $LOCKDIR >/dev/null 2>&1; then
	trap "cleanup" EXIT

	echo "Acquired lock, running"

	rm -f $LOCKDIR/*
	touch $LOCKDIR/$PID

	ping_cli
else
	exit 0
fi
