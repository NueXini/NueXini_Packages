#!/bin/sh

memtotal=`grep MemTotal /proc/meminfo | awk '{print $2}'`

#mem less than 64M
if test $memtotal -le 65536; then
	touch /tmp/natcapd.lck/gfwlist
	exit 0
fi

gfwlist_enable=`uci get natcapd.default.gfwlist_enable 2>/dev/null || echo 0`
[ x$gfwlist_enable = x1 ] || {
	touch /tmp/natcapd.lck/gfwlist
	exit 0
}

access_to_cn=`uci get natcapd.default.access_to_cn 2>/dev/null || echo 0`
[ x$access_to_cn = x1 ] && {
	touch /tmp/natcapd.lck/gfwlist
	exit 0
}

cnipwhitelist_mode=`uci get natcapd.default.cnipwhitelist_mode 2>/dev/null || echo 0`
exclude_domains=
[ x$cnipwhitelist_mode = x2 ] && \
exclude_domains="google appspot \
	blogspot gvt amazon \
	facebook fbcdn twitter \
	twimg netflix nflx \
	whatsapp youtube ytimg \
	gstatic ggpht \
	pscp apple"

exclude_out()
{
	cat "$1" >/tmp/gfwlist.$$.exclude_out.1
	for d in $exclude_domains; do
		cat /tmp/gfwlist.$$.exclude_out.1 | grep -v "$d" >/tmp/gfwlist.$$.exclude_out.2
		mv /tmp/gfwlist.$$.exclude_out.2 /tmp/gfwlist.$$.exclude_out.1
	done
	cat /tmp/gfwlist.$$.exclude_out.1 >"$1"
	rm -f /tmp/gfwlist.$$.exclude_out.1
}

gfw0_dns_magic_server=`uci get natcapd.default.gfw0_dns_magic_server 2>/dev/null || echo 8.8.8.8`

WGET=/usr/bin/wget
test -x $WGET || WGET=/bin/wget

EX_DOMAIN="google.com \
		   google.com.hk \
		   google.com.tw \
		   google.com.sg \
		   google.co.jp \
		   google.ae \
		   blogspot.com \
		   blogspot.sg \
		   blogspot.hk \
		   blogspot.jp \
		   gvt1.com \
		   gvt2.com \
		   gvt3.com \
		   1e100.net \
		   blogspot.tw \
		   fastly.net \
		   amazonaws.com"

$WGET --timeout=60 --no-check-certificate -qO /tmp/gfwlist.$$.txt "https://downloads.x-wrt.com/gfwlist.txt?t=`date '+%s'`" && {
	for w in `echo $EX_DOMAIN` `cat /tmp/gfwlist.$$.txt | base64 -d | grep -v ^! | grep -v ^@@ | grep -o '[a-zA-Z0-9][-a-zA-Z0-9]*[.][-a-zA-Z0-9.]*[a-zA-Z]$'`; do
		echo $w
	done | sort | uniq | while read line; do
		echo $line | grep -q github.com && continue
		echo server=/$line/$gfw0_dns_magic_server >>/tmp/accelerated-domains.gfwlist.dnsmasq.$$.conf
		echo ipset=/$line/gfwlist0 >>/tmp/accelerated-domains.gfwlist.dnsmasq.$$.conf
	done
	rm -f /tmp/gfwlist.$$.txt
	mkdir -p /tmp/dnsmasq.d && \
	mv /tmp/accelerated-domains.gfwlist.dnsmasq.$$.conf /tmp/dnsmasq.d/accelerated-domains.gfwlist.dnsmasq.conf && \
	exclude_out /tmp/dnsmasq.d/accelerated-domains.gfwlist.dnsmasq.conf

	touch /tmp/natcapd.lck/gfwlist
	/etc/init.d/dnsmasq restart
	exit 0
}
rm -f /tmp/gfwlist.$$.txt

test -f /tmp/dnsmasq.d/accelerated-domains.gfwlist.dnsmasq.conf && exit 0

mkdir -p /tmp/dnsmasq.d && \
cat /usr/share/natcapd/accelerated-domains.gfwlist.dnsmasq.conf | sed "s,/8.8.8.8,/$gfw0_dns_magic_server,g" >/tmp/dnsmasq.d/accelerated-domains.gfwlist.dnsmasq.conf
exclude_out /tmp/dnsmasq.d/accelerated-domains.gfwlist.dnsmasq.conf

/etc/init.d/dnsmasq restart

exit 0
