#!/bin/bash

# Copyright © Teal Dulcet
# Outputs system information
# wget -qO - https://raw.github.com/tdulcet/Linux-System-Information/master/info.sh | bash -s --
# ./info.sh

if [[ $# -ne 0 ]]; then
	echo "Usage: $0" >&2
	exit 1
fi

# Check if on Linux
if [[ $OSTYPE != linux* ]]; then
	echo "Error: This script must be run on Linux." >&2
	exit 1
fi

declare -A suffix_power=(["k"]=1 ["K"]=1 ["M"]=2 ["G"]=3 ["T"]=4 ["P"]=5 ["E"]=6 ["Z"]=7 ["Y"]=8 ["R"]=9 ["Q"]=10)

# outputunit <number> <scale_base>
outputunit() {
	echo "$*" | awk 'BEGIN { suffix[0]=""; suffix[1]="K"; suffix[2]="M"; suffix[3]="G"; suffix[4]="T"; suffix[5]="P"; suffix[6]="E"; suffix[7]="Z"; suffix[8]="Y"; suffix[9]="R"; suffix[10]="Q" } function abs(x) { return x<0 ? -x : x } { number=$1; scale_base=$2=="si" ? 1000 : 1024; power=0; while (abs(number)>=scale_base) { ++power; number /= scale_base } anumber=abs(number); anumber += anumber<10 ? 0.0005 : anumber<100 ? 0.005 : anumber<1000 ? 0.05 : 0.5; if (number!=0 && anumber<1000 && power>0) { str=sprintf("%.15g", number); alength=5 + (number<0); if (length(str) > alength) { prec=anumber<10 ? 3 : anumber<100 ? 2 : 1; str=sprintf("%." prec "f", number) } } else str=sprintf("%.0f", number); if (power>0) { str=str " " (power in suffix ? suffix[power] : "(error)"); if ($2=="iec-i") str=str "i" } print str }'
}

# inputunit <string> <scale_base>
inputunit() {
	local str=$1
	local scale_base sign int frac unit denominator

	case $2 in
		si) scale_base=1000 ;;
		iec | iec-i) scale_base=1024 ;;
	esac

	RE='^(([+-]?)([0-9]+)(\.([0-9]+))?)([[:space:]]*([kKMGTPEZYRQ])i?)?$'
	if [[ ! $str =~ $RE ]]; then
		printf 'Invalid number or suffix: %q\n' "$str" >&2
		return 1
	fi

	# number=${BASH_REMATCH[1]}
	sign=${BASH_REMATCH[2]}
	int=${BASH_REMATCH[3]}
	frac=${BASH_REMATCH[5]}
	unit=${BASH_REMATCH[7]}

	if [[ -n $unit ]]; then
		denominator=$((10 ** ${#frac}))

		echo $((($sign (10#$int * denominator + 10#${frac:-0}) * (scale_base ** suffix_power[$unit]) ${sign:-+} (denominator >> 1)) / denominator))
	else
		echo "$sign$int"
	fi
}

# toiec <KiB>
toiec() {
	echo "$(printf "%'d" $(($1 >> 10))) MiB$([[ $1 -ge 1048576 ]] && echo " ($(outputunit $(($1 << 10)) iec-i)B)")"
}

# tosi <KiB>
tosi() {
	echo "$(printf "%'d" $(((($1 << 10) / 1000) / 1000))) MB$([[ $1 -ge 1000000 ]] && echo " ($(outputunit $(($1 << 10)) si)B)")"
}

echo

if [[ -r /etc/os-release ]]; then
	. /etc/os-release
elif [[ -r /usr/lib/os-release ]]; then
	. /usr/lib/os-release
fi
echo -e "Linux Distribution:\t\t${ANSI_COLOR:+\e[${ANSI_COLOR}m}${PRETTY_NAME:-$NAME-$VERSION}${ANSI_COLOR:+\e[m}"

KERNEL=$(</proc/sys/kernel/osrelease) # uname -r
echo -e "Linux Kernel:\t\t\t$KERNEL"

file=/sys/class/dmi/id # /sys/devices/virtual/dmi/id
if [[ -d $file ]]; then
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
if [[ -n $MODEL ]]; then
	echo -e "Computer Model:\t\t\t$MODEL"
fi

case $HOSTTYPE in
	aarch64 | arm*)
		cpu=$(sed -n 's/^\(model name\|Processor\)[[:blank:]]*: *//p' /proc/cpuinfo)
		;;
	powerpc*) # ppc
		cpu=$(sed -n 's/^cpu[[:blank:]]*: *//p' /proc/cpuinfo)
		;;
	*)
		cpu=$(sed -n 's/^model name[[:blank:]]*: *//p' /proc/cpuinfo)
		;;
esac
mapfile -t CPU < <(echo "$cpu" | uniq)
if ! ((${#CPU[*]})) && command -v lscpu >/dev/null; then
	mapfile -t CPU < <(lscpu | grep -i '^model name' | sed -n 's/^.\+:[[:blank:]]*//p' | uniq)
fi
if ((${#CPU[*]})); then
	echo -e "Processor (CPU):\t\t${CPU[0]}$([[ ${#CPU[*]} -gt 1 ]] && printf '\n\t\t\t\t%s' "${CPU[@]:1}")"
fi

if command -v nproc >/dev/null; then
	CPU_THREADS=$(nproc --all)
else
	CPU_THREADS=$(getconf _NPROCESSORS_CONF) # $(lscpu | grep -i '^cpu(s)' | sed -n 's/^.\+:[[:blank:]]*//p')
fi
declare -A lists
for file in /sys/devices/system/cpu/cpu[0-9]*/topology/core_cpus_list; do
	if [[ -r $file ]]; then
		lists[$(<"$file")]=1
	fi
done
if ! ((${#lists[*]})); then
	for file in /sys/devices/system/cpu/cpu[0-9]*/topology/thread_siblings_list; do
		if [[ -r $file ]]; then
			lists[$(<"$file")]=1
		fi
	done
fi
CPU_CORES=${#lists[*]}
# CPU_CORES=$(lscpu -ap | grep -v '^#' | cut -d, -f2 | sort -nu | wc -l)
lists=()
for file in /sys/devices/system/cpu/cpu[0-9]*/topology/package_cpus_list; do
	if [[ -r $file ]]; then
		lists[$(<"$file")]=1
	fi
done
if ! ((${#lists[*]})); then
	for file in /sys/devices/system/cpu/cpu[0-9]*/topology/core_siblings_list; do
		if [[ -r $file ]]; then
			lists[$(<"$file")]=1
		fi
	done
fi
CPU_SOCKETS=${#lists[*]}
# CPU_SOCKETS=$(lscpu -ap | grep -v '^#' | cut -d, -f3 | sort -nu | wc -l) # $(lscpu | grep -i '^\(socket\|cluster\)(s)' | sed -n 's/^.\+:[[:blank:]]*//p' | tail -n 1)
echo -e "CPU Sockets/Cores/Threads:\t$CPU_SOCKETS/$CPU_CORES/$CPU_THREADS"

CPU_CACHES=()
declare -A CPU_NUM_CACHES CPU_CACHE_SIZES CPU_TOTAL_CACHE_SIZES
# CPU_L1I_CACHE_SIZE=$(getconf LEVEL1_ICACHE_SIZE)
# CPU_L1D_CACHE_SIZE=$(getconf LEVEL1_DCACHE_SIZE)
# CPU_L2_CACHE_SIZE=$(getconf LEVEL2_CACHE_SIZE)
# CPU_L3_CACHE_SIZE=$(getconf LEVEL3_CACHE_SIZE)
# CPU_L4_CACHE_SIZE=$(getconf LEVEL4_CACHE_SIZE)
lists=()
for dir in /sys/devices/system/cpu/cpu[0-9]*/cache; do
	if [[ -d $dir ]]; then
		for file in "$dir"/index[0-9]*/size; do
			if [[ -r $file ]]; then
				size=$(inputunit "$(<"$file")" iec)
				file=${file%/*}
				level=$(<"$file/level")
				type=$(<"$file/type")
				case $type in
					Data) type=d ;;
					Instruction) type=i ;;
					*) type='' ;;
				esac
				name="L$level$type"
				key="$(<"$file/shared_cpu_list") $name" # $file/shared_cpu_map
				if [[ -z ${lists[$key]} ]]; then
					if [[ -z ${CPU_TOTAL_CACHE_SIZES[$name]} ]]; then
						CPU_CACHES+=("$name")
					fi
					((++CPU_NUM_CACHES[$name]))
					((CPU_CACHE_SIZES[$name] = size > CPU_CACHE_SIZES[$name] ? size : CPU_CACHE_SIZES[$name]))
					((CPU_TOTAL_CACHE_SIZES[$name] += size))
					lists[$key]=1
				fi
			fi
		done
	fi
done
if ((${#CPU_CACHES[*]})); then
	echo -e -n "CPU Caches:\t\t\t"
	for i in "${!CPU_CACHES[@]}"; do
		cache=${CPU_CACHES[i]}
		((i)) && printf '\t\t\t\t'
		echo "$cache: $(printf "%'d" $((CPU_CACHE_SIZES[$cache] >> 10))) KiB × ${CPU_NUM_CACHES[$cache]} ($(outputunit "${CPU_TOTAL_CACHE_SIZES[$cache]}" iec-i)B)"
	done
fi

ARCHITECTURE=$(getconf LONG_BIT) # /sys/kernel/address_bits # printf '\1' | od -dAn
echo -e "Architecture:\t\t\t$HOSTTYPE (${ARCHITECTURE}-bit)" # arch, uname -m

MEMINFO=$(</proc/meminfo)
TOTAL_PHYSICAL_MEM=$(awk '/^MemTotal:/ { print $2 }' <<<"$MEMINFO") # (( $(getconf PAGE_SIZE) * $(getconf _PHYS_PAGES) ))
echo -e "Total memory (RAM):\t\t$(toiec "$TOTAL_PHYSICAL_MEM") ($(tosi "$TOTAL_PHYSICAL_MEM"))"

TOTAL_SWAP=$(awk '/^SwapTotal:/ { print $2 }' <<<"$MEMINFO")
echo -e "Total swap space:\t\t$(toiec "$TOTAL_SWAP") ($(tosi "$TOTAL_SWAP"))"

# DISKS=$(lsblk -dbn 2>/dev/null | awk '$6=="disk"')
DISK_NAMES=()
DISK_SIZES=()
for dir in /sys/block/*; do
	if [[ -d $dir ]]; then
		name=${dir##*/}
		if [[ -r "$dir/hidden" ]] && (($(<"$dir/hidden"))); then
			continue
		fi
		dev=$(<"$dir/dev")
		maj=${dev%%:*}
		if [[ $maj -eq 1 ]]; then
			continue
		fi
		size=$(<"$dir/size")
		if ! ((size)); then
			continue
		fi
		case $name in
			dm-* | loop* | md*) continue ;;
		esac
		if [[ ! -r "$dir/device/type" ]] || ! (($(<"$dir/device/type"))); then
			DISK_NAMES+=("$name")
			DISK_SIZES+=($((size << 9)))
		fi
	fi
done
if ((${#DISK_NAMES[*]})); then
	echo -e -n "Disk space:\t\t\t"
	for i in "${!DISK_NAMES[@]}"; do
		((i)) && printf '\t\t\t\t'
		echo -e "${DISK_NAMES[i]}: $(printf "%'d" $((DISK_SIZES[i] >> 20))) MiB$([[ ${DISK_SIZES[i]} -ge 1073741824 ]] && echo " ($(outputunit "${DISK_SIZES[i]}" iec-i)B)") ($(printf "%'d" $(((DISK_SIZES[i] / 1000) / 1000))) MB$([[ ${DISK_SIZES[i]} -ge 1000000000 ]] && echo " ($(outputunit "${DISK_SIZES[i]}" si)B)"))"
	done
fi

for lspci in lspci /sbin/lspci; do
	if command -v "$lspci" >/dev/null; then
		mapfile -t GPU < <($lspci 2>/dev/null | cut -d ' ' -f 2- | grep -i 'vga\|3d\|2d' | sed -n 's/^.*: //p')
		break
	fi
done
if ((${#GPU[*]})); then
	echo -e "Graphics Processor (GPU):\t${GPU[0]}$([[ ${#GPU[*]} -gt 1 ]] && printf '\n\t\t\t\t%s' "${GPU[@]:1}")"
fi

echo -e "Computer name:\t\t\t$HOSTNAME" # uname -n # hostname # /proc/sys/kernel/hostname

if command -v iw >/dev/null; then
	for dir in /sys/class/net/*; do
		if [[ -d $dir ]]; then
			inerface=${dir##*/}
			if [[ -d "$dir/wireless" ]]; then
				NETWORKNAME=$(iw dev "$inerface" link | sed -n 's/^[[:space:]]*SSID: //p')
				break
			fi
		fi
	done
elif command -v iwgetid >/dev/null; then
	NETWORKNAME=$(iwgetid -r || true)
fi
if [[ -n $NETWORKNAME ]]; then
	echo -e "Network name (SSID):\t\t$NETWORKNAME"
fi

HOSTNAME_FQDN=$(hostname -f) # hostname -A
echo -e "Hostname:\t\t\t$HOSTNAME_FQDN"

if command -v ip >/dev/null; then
	mapfile -t IPv4_ADDRESS < <(ip -o -4 a show up scope global | awk '{ print $2,$4 }')
	mapfile -t IPv6_ADDRESS < <(ip -o -6 a show up scope global | awk '{ print $2,$4 }')
fi
if ((${#IPv4_ADDRESS[*]})); then
	IPv4_INERFACES=($(printf '%s\n' "${IPv4_ADDRESS[@]}" | awk '{ print $1 }'))
	IPv4_ADDRESS=($(printf '%s\n' "${IPv4_ADDRESS[@]}" | awk '{ print $2 }'))
	echo -e -n "IPv4 address$([[ ${#IPv4_ADDRESS[*]} -gt 1 ]] && echo "es"):\t\t\t"
	for i in "${!IPv4_INERFACES[@]}"; do
		((i)) && printf '\t\t\t\t'
		echo -e "${IPv4_INERFACES[i]}: ${IPv4_ADDRESS[i]%/*}"
	done
fi
if ((${#IPv6_ADDRESS[*]})); then
	IPv6_INERFACES=($(printf '%s\n' "${IPv6_ADDRESS[@]}" | awk '{ print $1 }'))
	IPv6_ADDRESS=($(printf '%s\n' "${IPv6_ADDRESS[@]}" | awk '{ print $2 }'))
	echo -e -n "IPv6 address$([[ ${#IPv6_ADDRESS[*]} -gt 1 ]] && echo "es"):\t\t\t"
	for i in "${!IPv6_INERFACES[@]}"; do
		((i)) && printf '\t\t\t\t'
		echo -e "${IPv6_INERFACES[i]}: ${IPv6_ADDRESS[i]%/*}"
	done
fi

# ip -o l show up | grep -v 'loopback' | awk '{ print $2,$(NF-2) }'
# INERFACES=($(ip -o a show up primary scope global | awk '{ print $2 }' | uniq))
NET_INERFACES=()
NET_ADDRESSES=()
for dir in /sys/class/net/*; do
	if [[ -d $dir ]]; then
		inerface=${dir##*/}
		if (($(<"$dir/flags") & 0x1)) && [[ -r "$dir/address" ]]; then
			NET_INERFACES+=("$inerface")
			NET_ADDRESSES+=("$(<"$dir/address")")
		fi
	fi
done
if ((${#NET_INERFACES[*]})); then
	echo -e -n "MAC address$([[ ${#NET_INERFACES[*]} -gt 1 ]] && echo "es"):\t\t\t"
	for i in "${!NET_INERFACES[@]}"; do
		((i)) && printf '\t\t\t\t'
		echo -e "${NET_INERFACES[i]}: ${NET_ADDRESSES[i]}"
	done
fi

# hostid
if [[ -r /etc/machine-id ]]; then
	COMPUTER_ID=$(</etc/machine-id)
elif [[ -r /var/lib/dbus/machine-id ]]; then
	COMPUTER_ID=$(</var/lib/dbus/machine-id)
fi
echo -e "Computer ID:\t\t\t$COMPUTER_ID"

if [[ -r /etc/timezone ]]; then
	TIME_ZONE=$(</etc/timezone)
elif [[ -L /etc/localtime ]]; then
	TIME_ZONE=$(realpath --relative-to /usr/share/zoneinfo /etc/localtime) # readlink -f /etc/localtime
fi
if [[ -n $TIME_ZONE ]]; then
	TIME_ZONE+=$(printf ' (%(%Z, %z)T)') # date '+%Z, %z'
else
	TIME_ZONE=$(timedatectl 2>/dev/null | grep -i 'time zone:\|timezone:' | sed -n 's/^.*: //p') # timedatectl show --value -p Timezone
fi
echo -e "Time zone:\t\t\t$TIME_ZONE"

if command -v locale >/dev/null; then
	LANGUAGE=$(locale language)
fi
echo -e "Language:\t\t\t$LANG${LANGUAGE:+ ($LANGUAGE)}"

if command -v systemd-detect-virt >/dev/null && CONTAINER=$(systemd-detect-virt -c); then
	echo -e "Virtualization container:\t$CONTAINER"
fi

if command -v systemd-detect-virt >/dev/null && VM=$(systemd-detect-virt -v); then
	echo -e "Virtual Machine (VM) hypervisor:$VM"
fi

if LIBC_VERSION=$(getconf GNU_LIBC_VERSION 2>/dev/null); then # ldd --version | head -n 1 | awk '{ print $NF }'
	echo -e "libc Version:\t\t\t$LIBC_VERSION"
fi

echo -e "Bash Version:\t\t\t$BASH_VERSION"

if { exec {TTY_FD}<>/dev/tty; } 2>/dev/null; then
	old_stty=$(stty -g <&"$TTY_FD")

	stty raw min 0 time 10 <&"$TTY_FD"
	read -p $'\x05' -rs -t 1 -u "$TTY_FD" TERMINAL || true

	stty "$old_stty" <&"$TTY_FD"
	exec {TTY_FD}>&-
fi
if command -v tput >/dev/null; then
	# TERMINAL=$(tput longname 2>/dev/null)
	WIDTH=${COLUMNS:-$(tput cols 2>/dev/null)}
	HEIGHT=${LINES:-$(tput lines 2>/dev/null)}
	COLORS=$(tput colors 2>/dev/null)
else
	WIDTH=$COLUMNS
	HEIGHT=$LINES
fi
echo -e "\rTerminal:\t\t\t$TERM${TERMINAL:+ ($TERMINAL)}${WIDTH:+, $WIDTH columns}${HEIGHT:+, $HEIGHT lines}${COLORS:+, $COLORS colors}"

echo
