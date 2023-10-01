#!/bin/bash

# Teal Dulcet
# Outputs the systems public IP addresses
# wget https://raw.github.com/tdulcet/Linux-System-Information/master/ipinfo.sh -qO - | bash -s --
# ./ipinfo.sh

# Adapted from: https://github.com/rsp/scripts/blob/master/externalip.md

if [[ $# -ne 0 ]]; then
	echo "Usage: $0" >&2
	exit 1
fi

urls=(
	alma.ch/myip.cgi
	api.ipify.org/
	bot.whatismyipaddress.com/
	canhazip.com/
	checkip.amazonaws.com/
	curlmyip.net/
	diagnostic.opendns.com/myip
	echoip.de/
	eth0.me/
	icanhazip.com/
	ident.me/ # v4.ident.me/ # v6.ident.me/
	ifconfig.co/
	ifconfig.me/
	ifconfig.pro/
	ipaddr.site/
	ipecho.net/plain
	ipinfo.in/
	ipinfo.io/ip
	ip.tyk.nu/
	l2.io/ip
	myip.addr.space/
	tnx.nl/ip
	wgetip.com/
	ifconfig.io/ip
	# gso.cs.pdx.edu/ip/
)

echo -e "\nPublic IP addresses"

for ip in 4 6; do
	echo -e "\nIPv$ip address Best HTTPS response times:\n"
	
	for url in "${urls[@]}"; do
		cout=$(curl -"$ip" -m10 -sLw '\n%{time_total}\n' "https://$url" || true)
		answer=$(echo "$cout" | head -n 1)
		time=$(echo "$cout" | tail -n 1)
		printf '%s seconds\thttps://%s\t%s\n' "$time" "$url" "${answer:--}"
	done | sort -n | column -t -s $'\t'
done

echo
