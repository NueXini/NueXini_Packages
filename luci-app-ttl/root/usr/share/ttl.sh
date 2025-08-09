#!/bin/sh


SECTIONS=$(echo $(uci show ttl | awk -F [\]\[\@=] '/=ttl/{print $3}'))

get_vars(){
	for v in method advanced inet ports ttl iface proxy; do
		eval $v=$(uci -q get ttl.@ttl[${s}].${v} 2>/dev/nul)
	done
}


# check iptables or nft 
#
if [ -x /usr/sbin/iptables -o /usr/sbin/ip6tables -a ! -x /usr/sbin/nft ]; then
	. /usr/share/ttlipt.sh
else
	. /usr/share/ttlnft.sh
fi
