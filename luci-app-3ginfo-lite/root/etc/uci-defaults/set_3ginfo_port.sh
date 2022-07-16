#!/bin/sh
# Copyright 2020-2021 Rafał Wabik (IceG) - From eko.one.pl forum
# MIT License

chmod +x /usr/share/3ginfo-lite/3ginfo.sh
chmod +x /usr/share/3ginfo-lite/set_3ginfo_port.sh
chmod +x /usr/share/3ginfo-lite/3ginfo-hilink/alcatel_hilink.sh
chmod +x /usr/share/3ginfo-lite/3ginfo-hilink/huawei_hilink.sh
chmod +x /usr/share/3ginfo-lite/3ginfo-hilink/zte.sh
rm -rf /tmp/luci-indexcache
rm -rf /tmp/luci-modulecache/

work=false
for port in /dev/ttyUSB*
do
    [[ -e $port ]] || continue
    gcom -d $port info &> /tmp/testusb
    testUSB=`cat /tmp/testusb | grep "Error\|Can't"`
    if [ -z "$testUSB" ]; then 
        work=$port
        break
    fi
done
rm -rf /tmp/testusb

if [ $work != false ]; then
uci set 3ginfo.@3ginfo[0].device=$work
uci commit 3ginfo
fi
