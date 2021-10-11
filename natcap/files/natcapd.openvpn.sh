#!/bin/sh

test -x /etc/init.d/openvpn || exit 0

# gen natcap-ta.key if not exist.
test -f /etc/openvpn/natcap-ta.key || {
	mkdir -p /etc/openvpn
	openvpn --genkey --secret /etc/openvpn/natcap-ta.key
}

make_config()
{
	PROTO=$1
	PROTO=${PROTO-tcp}
	KEY_ID=client
	KEY_DIR=/usr/share/natcapd/openvpn
	BASE_CONFIG=/usr/share/natcapd/openvpn/client.conf
	hname=`cat /dev/natcap_ctl  | grep default_mac_addr | grep -o '[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]' | sed 's/://g'`
	TA_KEY=${KEY_DIR}/ta.key
	test -f /etc/openvpn/natcap-ta.key && TA_KEY=/etc/openvpn/natcap-ta.key

	cat ${BASE_CONFIG} | sed "s/^remote .*4911$/remote $hname.dns.x-wrt.com 4911/;s/^proto tcp$/proto $PROTO/"
	echo -e '<ca>'
	cat ${KEY_DIR}/ca.crt
	echo -e '</ca>\n<cert>'
	cat ${KEY_DIR}/${KEY_ID}.crt
	echo -e '</cert>\n<key>'
	cat ${KEY_DIR}/${KEY_ID}.key
	echo -e '</key>\n<tls-auth>'
	cat ${TA_KEY}
	echo -e '</tls-auth>'
}

[ "x$1" = "xgen_client" ] && {
	make_config tcp
	exit 0
}

[ "x$1" = "xgen_client_udp" ] && {
	make_config udp
	exit 0
}

[ "x`uci get natcapd.default.natcapovpn 2>/dev/null`" = x1 ] && {
	[ "x`uci get openvpn.natcapovpn_tcp.enabled 2>/dev/null`" != x1 ] && {
		/etc/init.d/openvpn stop
		uci delete network.natcapovpn
		uci set network.natcapovpn=interface
		uci set network.natcapovpn.proto='none'
		uci set network.natcapovpn.device='natcap+'
		uci set network.natcapovpn.auto='1'
		uci commit network

		index=0
		while :; do
			zone="`uci get firewall.@zone[$index].name 2>/dev/null`"
			test -n "$zone" || break
			[ "x$zone" = "xlan" ] && {
				lans="`uci get firewall.@zone[$index].network`"
				uci delete firewall.@zone[$index].network
				for w in natcapovpn $lans; do
					uci add_list firewall.@zone[$index].network="$w"
				done
				break
			}
			index=$((index+1))
		done
		for p in tcp udp; do
			uci delete firewall.natcapovpn_$p
			uci set firewall.natcapovpn_$p=rule
			uci set firewall.natcapovpn_$p.target='ACCEPT'
			uci set firewall.natcapovpn_$p.src='wan'
			uci set firewall.natcapovpn_$p.proto="$p"
			uci set firewall.natcapovpn_$p.dest_port='4911'
			uci set firewall.natcapovpn_$p.name="natcapovpn_$p"
		done
		uci commit firewall

		I=0
		for p in tcp udp; do
			uci delete openvpn.natcapovpn_$p
			uci set openvpn.natcapovpn_$p=openvpn
			uci set openvpn.natcapovpn_$p.enabled='1'
			uci set openvpn.natcapovpn_$p.port='4911'
			uci set openvpn.natcapovpn_$p.dev="natcap$p"
			uci set openvpn.natcapovpn_$p.dev_type='tun'
			uci set openvpn.natcapovpn_$p.ca='/usr/share/natcapd/openvpn/ca.crt'
			uci set openvpn.natcapovpn_$p.cert='/usr/share/natcapd/openvpn/server.crt'
			uci set openvpn.natcapovpn_$p.key='/usr/share/natcapd/openvpn/server.key'
			uci set openvpn.natcapovpn_$p.dh='/usr/share/natcapd/openvpn/dh2048.pem'
			uci set openvpn.natcapovpn_$p.server="10.8.$((9+I)).0 255.255.255.0"
			uci set openvpn.natcapovpn_$p.keepalive='10 120'
			uci set openvpn.natcapovpn_$p.persist_key='1'
			uci set openvpn.natcapovpn_$p.persist_tun='1'
			uci set openvpn.natcapovpn_$p.user='nobody'
			uci set openvpn.natcapovpn_$p.duplicate_cn='1'
			uci set openvpn.natcapovpn_$p.status='/tmp/natcapovpn-status.log'
			uci set openvpn.natcapovpn_$p.mode='server'
			uci set openvpn.natcapovpn_$p.tls_server='1'
			uci set openvpn.natcapovpn_$p.tls_auth='/usr/share/natcapd/openvpn/ta.key 0'
			test -f /etc/openvpn/natcap-ta.key && uci set openvpn.natcapovpn_$p.tls_auth='/etc/openvpn/natcap-ta.key 0'
			uci set openvpn.natcapovpn_$p.client_to_client='1'
			uci add_list openvpn.natcapovpn_$p.push='persist-key'
			uci add_list openvpn.natcapovpn_$p.push='persist-tun'
			uci add_list openvpn.natcapovpn_$p.push='dhcp-option DNS 8.8.8.8'
			uci set openvpn.natcapovpn_$p.proto="${p}4"
			uci set openvpn.natcapovpn_$p.verb='3'
			uci set openvpn.natcapovpn_$p.cipher='AES-256-CBC'
			uci set openvpn.natcapovpn_$p.auth='SHA256'
			I=$((I+1))
		done
		uci commit openvpn

		/etc/init.d/openvpn start
		/etc/init.d/network reload
		/etc/init.d/firewall reload
	}
	exit 0
}

[ "x`uci get natcapd.default.natcapovpn 2>/dev/null`" != x1 ] && [ "x`uci get openvpn.natcapovpn_tcp.enabled 2>/dev/null`" = x1 ] && {
	/etc/init.d/openvpn stop
	for p in tcp udp; do
		uci delete openvpn.natcapovpn_$p
	done
	uci commit openvpn

	uci delete network.natcapovpn
	uci commit network

	for p in tcp udp; do
		uci delete firewall.natcapovpn_$p
	done
	index=0
	while :; do
		zone="`uci get firewall.@zone[$index].name 2>/dev/null`"
		test -n "$zone" || break
		[ "x$zone" = "xlan" ] && {
			lans="`uci get firewall.@zone[$index].network`"
			uci delete firewall.@zone[$index].network
			for w in natcapovpn $lans; do
				[ "x$w" = "xnatcapovpn" ] && continue
				uci add_list firewall.@zone[$index].network="$w"
			done
			break
		}
		index=$((index+1))
	done
	uci commit firewall

	/etc/init.d/openvpn start
	/etc/init.d/network reload
	/etc/init.d/firewall reload
	exit 0
}
