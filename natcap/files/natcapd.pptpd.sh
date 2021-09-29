#!/bin/sh

[ "x`uci get natcapd.default.pptpd`" = x1 ] && {
	! [ "x`uci get pptpd.pptpd.enabled`" = x1 ] && {
		uci delete network.natcapd
		uci set network.natcapd=interface
		uci set network.natcapd.proto='none'
		uci set network.natcapd.device='pcap+'
		uci set network.natcapd.auto='1'
		uci commit network

		index=0
		while :; do
			zone="`uci get firewall.@zone[$index].name 2>/dev/null`"
			test -n "$zone" || break
			[ "x$zone" = "xlan" ] && {
				obj=`uci add firewall zone`
				for key in `uci show firewall.@zone[$index] | grep "firewall\..*\." | cut -d\. -f3 | cut -d= -f1`; do
					uci set firewall.$obj.$key=`uci get firewall.@zone[$index].$key`
				done
				lans="`uci get firewall.@zone[$index].network`"
				uci delete firewall.$obj.network
				for w in natcapd $lans; do
					uci add_list firewall.$obj.network="$w"
				done
				uci delete firewall.@zone[$index]
				break
			}
			index=$((index+1))
		done
		uci delete firewall.natcapd_pptp_tcp
		uci set firewall.natcapd_pptp_tcp=rule
		uci set firewall.natcapd_pptp_tcp.target='ACCEPT'
		uci set firewall.natcapd_pptp_tcp.src='wan'
		uci set firewall.natcapd_pptp_tcp.proto='tcp'
		uci set firewall.natcapd_pptp_tcp.dest_port='1723'
		uci set firewall.natcapd_pptp_tcp.name='pptp'
		uci delete firewall.natcapd_pptp_gre
		uci set firewall.natcapd_pptp_gre=rule
		uci set firewall.natcapd_pptp_gre.enabled='1'
		uci set firewall.natcapd_pptp_gre.target='ACCEPT'
		uci set firewall.natcapd_pptp_gre.src='wan'
		uci set firewall.natcapd_pptp_gre.name='gre'
		uci set firewall.natcapd_pptp_gre.proto='gre'
		uci commit firewall

		/etc/init.d/network reload
		/etc/init.d/firewall reload

		uci set pptpd.pptpd=service
		uci set pptpd.pptpd.enabled='1'
		uci set pptpd.pptpd.localip='10.8.8.1'
		uci set pptpd.pptpd.remoteip='10.8.8.10-254'
		uci set pptpd.pptpd.natcapd='1'
		uci set pptpd.pptpd.logwtmp='0'
		uci commit pptpd
	}

	pptpusers=""
	index=0
	while :; do
		user="`uci get natcapd.@pptpuser[$index].username 2>/dev/null`"
		test -n "$user" || break
		pass="`uci get natcapd.@pptpuser[$index].password 2>/dev/null`"
		test -n "$pass" || break
		pptpusers="$pptpusers-$user$pass"
		index=$((index+1))
	done
	newmd5=`echo -n $pptpusers | md5sum | awk '{print $1}'`
	oldmd5=`uci get pptpd.pptpd.pptpuser_md5 2>/dev/null`
	[ "x${newmd5}" = "x${oldmd}" ] || {
		while uci delete pptpd.@login[0] 2>/dev/null; do :; done
		index=0
		while :; do
			user="`uci get natcapd.@pptpuser[$index].username 2>/dev/null`"
			test -n "$user" || break
			pass="`uci get natcapd.@pptpuser[$index].password 2>/dev/null`"
			test -n "$pass" || break

			obj=`uci add pptpd login`
			test -n "$obj" && {
				uci set pptpd.$obj.username="$user"
				uci set pptpd.$obj.password="$pass"
			}
			index=$((index+1))
		done
		uci set pptpd.pptpd.pptpuser_md5="${newmd5}"
		uci commit pptpd
	}

	cat /etc/ppp/options.pptpd | sed 's/^#ms-dns.*/ms-dns 10.8.8.1/g' >/tmp/options.pptpd
	diff -q /tmp/options.pptpd /etc/ppp/options.pptpd >/dev/null || cp /tmp/options.pptpd /etc/ppp/options.pptpd
	rm -f /tmp/options.pptpd

	rm -f /var/etc/chap-secrets
	/etc/init.d/pptpd restart
	exit 0
}

! [ "x`uci get natcapd.default.pptpd`" = x1 ] && [ "x`uci get pptpd.pptpd.enabled`" = x1 ] && uci get pptpd.pptpd.natcapd && {
	uci set pptpd.pptpd.enabled='0'
	uci commit pptpd
	/etc/init.d/pptpd stop

	uci delete network.natcapd
	uci commit network

	uci delete firewall.natcapd_pptp_tcp
	uci delete firewall.natcapd_pptp_gre
	index=0
	while :; do
		zone="`uci get firewall.@zone[$index].name 2>/dev/null`"
		test -n "$zone" || break
		[ "x$zone" = "xlan" ] && {
			lans="`uci get firewall.@zone[$index].network`"
			uci delete firewall.@zone[$index].network
			for w in natcapd $lans; do
				[ "x$w" = "xnatcapd" ] && continue
				uci add_list firewall.@zone[$index].network="$w"
			done
			break
		}
		index=$((index+1))
	done
	uci commit firewall

	/etc/init.d/network reload
	/etc/init.d/firewall reload
	exit 0
}
