#!/bin/bash

# Teal Dulcet
# Outputs system information
# wget https://raw.github.com/tdulcet/Linux-System-Information/master/info.sh -qO - | bash -s --
# ./info.sh

if [[ $# -ne 0 ]]; then
	echo "Usage: $0" >&2
	exit 1
fi

# Check if on Linux
if ! echo "$OSTYPE" | grep -iq "linux"; then
	echo "Error: This script must be run on Linux." >&2
	exit 1
fi

# toiec <KiB>
toiec() {
	echo "$(printf "%'d" $(( $1 / 1024 ))) MiB$([[ $1 -ge 1048576 ]] && echo " ($(numfmt --from=iec --to=iec-i "${1}K")B)")"
}

# tosi <KiB>
tosi() {
	echo "$(printf "%'d" $(( (($1 * 1024) / 1000) / 1000 ))) MB$([[ $1 -ge 1000000 ]] && echo " ($(numfmt --from=iec --to=si "${1}K")B)")"
}

. /etc/os-release

echo -e "\nLinux Distribution:\t\t${PRETTY_NAME:-$ID-$VERSION_ID}"

KERNEL=$(</proc/sys/kernel/osrelease) # uname -r
echo -e "Linux Kernel:\t\t\t$KERNEL"

file=/sys/class/dmi/id # /sys/devices/virtual/dmi/id
if [[ -d "$file" ]]; then
	if [[ -r "$file/sys_vendor" ]]; then
		MODEL=$(<"$file/sys_vendor")
	elif [[ -r "$file/board_vendor" ]]; then
		MODEL=$(<"$file/board_vendor")
	elif [[ -r "$file/chassis_vendor" ]]; then
		MODEL=$(<"$file/chassis_vendor")
	fi
	if [[ -r "$file/product_name" ]]; then
		MODEL+=" $(<"$file/product_name")"
	fi
	if [[ -r "$file/product_version" ]]; then
		MODEL+=" $(<"$file/product_version")"
	fi
elif [[ -r /sys/firmware/devicetree/base/model ]]; then
	read -r -d '' MODEL </sys/firmware/devicetree/base/model
fi
if [[ -n "$MODEL" ]]; then
	echo -e "Computer Model:\t\t\t$MODEL"
fi

mapfile -t CPU < <(sed -n 's/^model name[[:blank:]]*: *//p' /proc/cpuinfo | uniq)
if [[ -z "$CPU" ]]; then
	mapfile -t CPU < <(lscpu | grep -i '^model name' | sed -n 's/^.\+:[[:blank:]]*//p' | uniq)
fi
if [[ -n "$CPU" ]]; then
	echo -e "Processor (CPU):\t\t${CPU[0]}$([[ ${#CPU[*]} -gt 1 ]] && printf '\n\t\t\t\t%s' "${CPU[@]:1}")"
fi

CPU_THREADS=$(nproc --all) # getconf _NPROCESSORS_CONF # $(lscpu | grep -i '^cpu(s)' | sed -n 's/^.\+:[[:blank:]]*//p')
CPU_CORES=$(lscpu -ap | grep -v '^#' | awk -F, '{ print $2 }' | sort -nu | wc -l)
CPU_SOCKETS=$(lscpu | grep -i '^\(socket\|cluster\)(s)' | sed -n 's/^.\+:[[:blank:]]*//p' | tail -n 1) # $(lscpu -ap | grep -v '^#' | awk -F, '{ print $3 }' | sort -nu | wc -l)
echo -e "CPU Sockets/Cores/Threads:\t$CPU_SOCKETS/$CPU_CORES/$CPU_THREADS"

ARCHITECTURE=$(getconf LONG_BIT)
echo -e "Architecture:\t\t\t$HOSTTYPE (${ARCHITECTURE}-bit)" # arch, uname -m

MEMINFO=$(</proc/meminfo)
TOTAL_PHYSICAL_MEM=$(echo "$MEMINFO" | awk '/^MemTotal:/ { print $2 }') # (( $(getconf PAGE_SIZE) * $(getconf _PHYS_PAGES) ))
echo -e "Total memory (RAM):\t\t$(toiec "$TOTAL_PHYSICAL_MEM") ($(tosi "$TOTAL_PHYSICAL_MEM"))"

TOTAL_SWAP=$(echo "$MEMINFO" | awk '/^SwapTotal:/ { print $2 }')
echo -e "Total swap space:\t\t$(toiec "$TOTAL_SWAP") ($(tosi "$TOTAL_SWAP"))"

DISKS=$(lsblk -dbn 2>/dev/null | awk '$6=="disk"')
if [[ -n "$DISKS" ]]; then
	DISK_NAMES=( $(echo "$DISKS" | awk '{ print $1 }') )
	DISK_SIZES=( $(echo "$DISKS" | awk '{ print $4 }') )
	echo -e -n "Disk space:\t\t\t"
	for i in "${!DISK_NAMES[@]}"; do
		echo -e "$([[ $i -gt 0 ]] && echo "\t\t\t\t")${DISK_NAMES[i]}: $(printf "%'d" $(( (DISK_SIZES[i] / 1024) / 1024 ))) MiB$([[ ${DISK_SIZES[i]} -ge 1073741824 ]] && echo " ($(numfmt --to=iec-i "${DISK_SIZES[i]}")B)") ($(printf "%'d" $(( (DISK_SIZES[i] / 1000) / 1000 ))) MB$([[ ${DISK_SIZES[i]} -ge 1000000000 ]] && echo " ($(numfmt --to=si "${DISK_SIZES[i]}")B)"))"
	done
fi

for lspci in lspci /sbin/lspci; do
	if command -v $lspci >/dev/null; then
		mapfile -t GPU < <($lspci 2>/dev/null | grep -i 'vga\|3d\|2d' | sed -n 's/^.*: //p')
		break
	fi
done
if [[ -n "$GPU" ]]; then
	echo -e "Graphics Processor (GPU):\t${GPU[0]}$([[ ${#GPU[*]} -gt 1 ]] && printf '\n\t\t\t\t%s' "${GPU[@]:1}")"
fi

echo -e "Computer name:\t\t\t$HOSTNAME" # uname -n # hostname # /proc/sys/kernel/hostname

if command -v iwgetid >/dev/null; then
	NETWORKNAME=$(iwgetid -r || true)
fi
if [[ -n "$NETWORKNAME" ]]; then
	echo -e "Network name (SSID):\t\t$NETWORKNAME"
fi

HOSTNAME_FQDN=$(hostname -f) # hostname -A
echo -e "Hostname:\t\t\t$HOSTNAME_FQDN"

mapfile -t IPv4_ADDRESS < <(ip -o -4 a show up scope global | awk '{ print $2,$4 }')
if [[ -n "$IPv4_ADDRESS" ]]; then
	IPv4_INERFACES=( $(printf '%s\n' "${IPv4_ADDRESS[@]}" | awk '{ print $1 }') )
	IPv4_ADDRESS=( $(printf '%s\n' "${IPv4_ADDRESS[@]}" | awk '{ print $2 }') )
	echo -e -n "IPv4 address$([[ ${#IPv4_ADDRESS[*]} -gt 1 ]] && echo "es"):\t\t\t"
	for i in "${!IPv4_INERFACES[@]}"; do
		echo -e "$([[ $i -gt 0 ]] && echo "\t\t\t\t")${IPv4_INERFACES[i]}: ${IPv4_ADDRESS[i]%/*}"
	done
fi
mapfile -t IPv6_ADDRESS < <(ip -o -6 a show up scope global | awk '{ print $2,$4 }')
if [[ -n "$IPv6_ADDRESS" ]]; then
	IPv6_INERFACES=( $(printf '%s\n' "${IPv6_ADDRESS[@]}" | awk '{ print $1 }') )
	IPv6_ADDRESS=( $(printf '%s\n' "${IPv6_ADDRESS[@]}" | awk '{ print $2 }') )
	echo -e -n "IPv6 address$([[ ${#IPv6_ADDRESS[*]} -gt 1 ]] && echo "es"):\t\t\t"
	for i in "${!IPv6_INERFACES[@]}"; do
		echo -e "$([[ $i -gt 0 ]] && echo "\t\t\t\t")${IPv6_INERFACES[i]}: ${IPv6_ADDRESS[i]%/*}"
	done
fi

# ip -o l show up | grep -v 'loopback' | awk '{ print $2,$(NF-2) }'
INERFACES=( $(ip -o a show up primary scope global | awk '{ print $2 }' | uniq) )
NET_INERFACES=()
NET_ADDRESSES=()
for inerface in "${INERFACES[@]}"; do
	file="/sys/class/net/$inerface"
	if [[ -r "$file/address" ]]; then
		NET_INERFACES+=( "$inerface" )
		NET_ADDRESSES+=( "$(<"$file/address")" )
	fi
done
if [[ -n "$NET_INERFACES" ]]; then
	echo -e -n "MAC address$([[ ${#NET_INERFACES[*]} -gt 1 ]] && echo "es"):\t\t\t"
	for i in "${!NET_INERFACES[@]}"; do
		echo -e "$([[ $i -gt 0 ]] && echo "\t\t\t\t")${NET_INERFACES[i]}: ${NET_ADDRESSES[i]}"
	done
fi

if [[ -r /var/lib/dbus/machine-id ]]; then
	COMPUTER_ID=$(</var/lib/dbus/machine-id)
	echo -e "Computer ID:\t\t\t$COMPUTER_ID"
fi

TIME_ZONE=$(timedatectl 2>/dev/null | grep -i 'time zone:\|timezone:' | sed -n 's/^.*: //p')
echo -e "Time zone:\t\t\t$TIME_ZONE"

echo -e "Language:\t\t\t$LANG"

if command -v systemd-detect-virt >/dev/null && CONTAINER=$(systemd-detect-virt -c); then
	echo -e "Virtualization container:\t$CONTAINER"
fi

if command -v systemd-detect-virt >/dev/null && VM=$(systemd-detect-virt -v); then
	echo -e "Virtual Machine (VM) hypervisor:$VM"
fi

echo -e "Bash Version:\t\t\t$BASH_VERSION"

if [[ -c /dev/tty ]]; then
	stty raw min 0 time 10 </dev/tty
	read -p $'\x05' -rs -t 1 TERMINAL </dev/tty || true
	stty cooked </dev/tty
fi
echo -e "\rTerminal:\t\t\t$TERM${TERMINAL:+ ($TERMINAL)}"

echo
