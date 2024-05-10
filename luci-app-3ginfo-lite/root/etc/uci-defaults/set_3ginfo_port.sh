#!/bin/sh
# Copyright 2020-2024 Rafał Wabik (IceG) - From eko.one.pl forum
# MIT License

chmod +x /usr/share/3ginfo-lite/3ginfo.sh 2>&1 &
chmod +x /usr/share/3ginfo-lite/detect.sh 2>&1 &
chmod +x /usr/share/3ginfo-lite/check.gcom 2>&1 &
chmod +x /usr/share/3ginfo-lite/info.gcom 2>&1 &
chmod +x /usr/share/3ginfo-lite/vendorproduct.gcom 2>&1 &
chmod +x /usr/share/3ginfo-lite/modem/hilink/alcatel_hilink.sh 2>&1 &
chmod +x /usr/share/3ginfo-lite/modem/hilink/huawei_hilink.sh 2>&1 &
chmod +x /usr/share/3ginfo-lite/modem/hilink/zte.sh 2>&1 &
rm -rf /tmp/luci-indexcache 2>&1 &
rm -rf /tmp/luci-modulecache/ 2>&1 &

exit 0

