#!/bin/bash

# Teal Dulcet
# Outputs system information
# wget https://raw.github.com/tdulcet/Linux-System-Information/master/info.sh -qO - | bash -s --
# ./info.sh

if [[ "$#" -ne 0 ]]; then
	echo "Usage: $0" >&2
	exit 1
fi

# Check if on Linux
if ! echo "$OSTYPE" | grep -iq "linux"; then
	echo "Error: This script must be run on Linux." >&2
	exit 1
fi

. /etc/os-release

echo -e "\nLinux Distribution:\t\t${PRETTY_NAME:-$ID-$VERSION_ID}"

KERNEL=$(uname -r)
echo -e "Linux Kernel:\t\t\t$KERNEL"

mapfile -t CPU < <(sed -n 's/^model name[[:space:]]*: *//p' /proc/cpuinfo | uniq)
if [[ -n "$CPU" ]]; then
	echo -e "Processor (CPU):\t\t${CPU[0]}$([[ ${#CPU[*]} -gt 1 ]] && echo; printf '\t\t\t\t%s\n' "${CPU[@]:1}")"
fi

CPU_THREADS=$(nproc --all) # $(lscpu | grep -i '^cpu(s)' | sed -n 's/^.\+:[[:blank:]]*//p')
CPU_CORES=$(( CPU_THREADS / $(lscpu | grep -i '^thread(s) per core' | sed -n 's/^.\+:[[:blank:]]*//p') ))
echo -e "CPU Cores/Threads:\t\t$CPU_CORES/$CPU_THREADS"

ARCHITECTURE=$(getconf LONG_BIT)
echo -e "Architecture:\t\t\t$HOSTTYPE (${ARCHITECTURE}-bit)"

TOTAL_PHYSICAL_MEM=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
echo -e "Total memory (RAM):\t\t$(printf "%'d" $((TOTAL_PHYSICAL_MEM / 1024))) MiB ($(printf "%'d" $((((TOTAL_PHYSICAL_MEM * 1024) / 1000) / 1000))) MB)"

TOTAL_SWAP=$(awk '/^SwapTotal:/ {print $2}' /proc/meminfo)
echo -e "Total swap space:\t\t$(printf "%'d" $((TOTAL_SWAP / 1024))) MiB ($(printf "%'d" $((((TOTAL_SWAP * 1024) / 1000) / 1000))) MB)"

if command -v lspci >/dev/null; then
	mapfile -t GPU < <(lspci 2>/dev/null | grep -i 'vga\|3d\|2d' | sed -n 's/^.*: //p')
fi
if [[ -n "$GPU" ]]; then
	echo -e "Graphics Processor (GPU):\t${GPU[0]}$([[ ${#GPU[*]} -gt 1 ]] && echo; printf '\t\t\t\t%s\n' "${GPU[@]:1}")"
fi

echo -e "Computer name:\t\t\t$HOSTNAME"

HOSTNAME_FQDN=$(hostname -f) # hostname -A
echo -e "Hostname:\t\t\t$HOSTNAME_FQDN"

IP_ADDRESS=( $(hostname -I) )
echo -e "IP address$([[ ${#IP_ADDRESS[*]} -gt 1 ]] && echo "es"):\t\t\t${IP_ADDRESS[0]}$([[ ${#IP_ADDRESS[*]} -gt 1 ]] && echo; printf '\t\t\t\t%s\n' "${IP_ADDRESS[@]:1}")"

TIME_ZONE=$(timedatectl 2>/dev/null | grep -i 'time zone:\|timezone:' | sed -n 's/^.*: //p')
echo -e "Time zone:\t\t\t$TIME_ZONE"

echo -e "Language:\t\t\t$LANG"

if command -v systemd-detect-virt >/dev/null && CONTAINER=$(systemd-detect-virt -c); then
	echo -e "Virtualization container:\t$CONTAINER"
fi

if command -v systemd-detect-virt >/dev/null && VM=$(systemd-detect-virt -v); then
	echo -e "Virtual Machine (VM) hypervisor:$VM"
fi

echo
