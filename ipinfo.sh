#!/bin/bash

# Copyright © Teal Dulcet
# Outputs the systems public IP addresses
# wget -qO - https://raw.github.com/tdulcet/Linux-System-Information/master/ipinfo.sh | bash -s --
# ./ipinfo.sh

# Adapted from: https://github.com/rsp/scripts/blob/master/externalip-benchmark.md

if [[ $# -ne 0 ]]; then
	echo "Usage: $0" >&2
	exit 1
fi

URLS=(
	alma.ch/myip.cgi
	api.ipify.org/
	# bot.whatismyipaddress.com/
	canhazip.com/
	checkip.amazonaws.com/
	curlmyip.net/
	# diagnostic.opendns.com/myip
	echoip.de/
	eth0.me/
	icanhazip.com/
	ident.me/ # v4.ident.me/ # v6.ident.me/
	ifconfig.co/
	ifconfig.me/ip
	ifconfig.pro/
	ipaddr.site/
	ipecho.net/plain
	ipinfo.in/
	ipinfo.io/ip
	ip.tyk.nu/
	l2.io/ip
	# myip.addr.space/
	tnx.nl/ip
	wgetip.com/
	ifconfig.io/ip
	silisoftware.com/tools/ip.php
	corz.org/ip
	ifcfg.me/
	api.infoip.io/ip
	whatismyip.akamai.com/
	ip-adresim.app/
	ipaddress.sh/
	myexternalip.com/raw
	myip.dnsomatic.com/
	trackip.net/ip
	wtfismyip.com/text
	myip.wtf/text
	ipapi.co/ip
	ip2location.io/ip
	checkip.spdyn.de/
	www.nsupdate.info/myip
	ip.changeip.com/
	# gso.cs.pdx.edu/ip/
)

SERVERS=(
	one.one.one.one
	dns.opendns.com
	resolver{1..4}.opendns.com
	ns1-1.akamaitech.net
	ns{1..4}.google.com
)

NAMES=(
	whoami.cloudflare
	myip.opendns.com
	myip.opendns.com{,,,}
	whoami.akamai.net
	o-o.myaddr.l.google.com{,,,}
)

TYPES=(
	TXT
	''
	''{,,,}
	''
	''{,,,}
)

CLASSES=(
	CH
	''
	''{,,,}
	''
	''{,,,}
)

echo -e "\nPublic IP addresses"

for ip in 4 6; do
	echo -e "\nBest HTTPS response times IPv$ip address:\n"

	for url in "${URLS[@]}"; do
		answer=''
		if output=$(curl -"$ip" -m10 -sSfLw '\n%{time_total}\n' "https://$url" 2>&1); then
			answer=$(echo "$output" | head -n 1)
		fi
		time=$(echo "$output" | tail -n 1)
		printf '%s seconds \thttps://%s\t%s\n' "$time" "$url" "${answer:--}"
	done | sort -n | awk -F'[ ]' '{ $1 *= 1000; $2 = "ms"; print }' | column -t -s $'\t'
done

for ip in 4 6; do
	echo -e "\nBest DNS response times IPv$ip address:\n"

	for i in "${!SERVERS[@]}"; do
		answer=''
		if output=$(dig -"$ip" -u "@${SERVERS[i]}" "${NAMES[i]}" "${TYPES[i]:-IN}" "${CLASSES[i]:-ANY}" 2>&1); then
			answer=$(echo "$output" | grep -v '^;' | awk '$4 == "A" || $4 == "AAAA" || $4 == "TXT" { print $4"\t"$5 }' | head -n 1)
		fi
		time=$(echo "$output" | sed -n 's/;; Query time: *//p')
		printf '%s \t%s\t%s\t%s\n' "${time:-0 usec}" "${SERVERS[i]}" "${NAMES[i]}" "${answer:--}"
	done | sort -n | awk -F'[ ]' '{ $1 /= 1000; $2 = "ms"; print }' | column -t -s $'\t'
done

echo
