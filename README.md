[![CI](https://github.com/tdulcet/Linux-System-Information/actions/workflows/ci.yml/badge.svg)](https://github.com/tdulcet/Linux-System-Information/actions/workflows/ci.yml)

# Linux System Information
Linux System Information Script

Copyright © 2019 Teal Dulcet

Simple script to quickly output system information on Linux, including:

* Linux distribution
* Computer Model
* Processor (CPU)
* CPU sockets/cores/threads
* CPU caches
* Architecture
* Total memory (RAM)
* Total swap space
* Disk space
* \*Graphics Processor (GPU)
* Hostname (FQDN)
* IP address(es)
* MAC address(es)
* Time zone
* Language
* \*Virtualization container
* \*Virtual Machine (VM) hypervisor

\* If present

RAM, swap and disk space is output in both MiB (1024<sup>2</sup> bytes) and MB (1000<sup>2</sup> bytes). Similar to the [`systeminfo`](https://en.wikipedia.org/wiki/Systeminfo.exe) command on Windows.

Requires at least Bash 4+. Compared to similar programs, this script outputs much more information and is smaller. Useful when using an unfamiliar system or VM, particularly before running a program that has specific system requirements. All the values are saved to variables, which makes this easy to [incorporate](#scripts-where-this-is-incorporated) into larger scripts.

For your Public IP addresses, please see [Public IP addresses](#public-ip-addresses) below.

❤️ Please visit [tealdulcet.com](https://www.tealdulcet.com/) to support this script and my other software development.

Also see the [Linux System Usage Information](https://github.com/tdulcet/System-Usage-Information) script.

## Usage

Supports all modern Linux distributions from the last 12+ years, including [BusyBox](https://en.wikipedia.org/wiki/BusyBox), [Toybox](https://en.wikipedia.org/wiki/Toybox) and the [Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) (WSL).

### wget

```bash
wget -qO - https://raw.github.com/tdulcet/Linux-System-Information/master/info.sh | bash -s
```

### curl

```bash
curl -sfL https://raw.github.com/tdulcet/Linux-System-Information/master/info.sh | bash -s
```

## Example Output

```

Linux Distribution:             Debian GNU/Linux 11 (bullseye)
Linux Kernel:                   6.1.21-v8+
Computer Model:                 Raspberry Pi 4 Model B Rev 1.2
Processor (CPU):                Cortex-A72
CPU Sockets/Cores/Threads:      1/4/4
CPU Caches:                     L1d: 32 KiB × 4 (128KiB)
                                L1i: 48 KiB × 4 (192KiB)
                                L2: 1,024 KiB × 1 (1.0MiB)
Architecture:                   aarch64 (64-bit)
Total memory (RAM):             3,794 MiB (3.8GiB) (3,978 MB (4.0GB))
Total swap space:               99 MiB (104 MB)
Disk space:                     mmcblk0: 60,906 MiB (60GiB) (63,864 MB (64GB))
Computer name:                  raspberrypi
Network name (SSID):            Teal's Network
Hostname:                       raspberrypi
IPv4 address:                   wlan0: 10.2.248.100
MAC address:                    wlan0: dc:a6:32:67:46:f2
Computer ID:                    ce7d0b99f428492a882941fed3c58c06
Time zone:                      America/Los_Angeles (PDT, -0700)
Language:                       en_US.UTF-8 (American English)
libc Version:                   glibc 2.31
Bash Version:                   5.1.4(1)-release
Terminal:                       xterm-256color, 198 columns, 53 lines, 256 colors

```

## Scripts where this is incorporated

* [Linux Distributed Computing Scripts](https://github.com/tdulcet/Distributed-Computing-Scripts)
* [Mail-in-a-Box](https://github.com/mail-in-a-box/mailinabox) ([pending](https://github.com/mail-in-a-box/mailinabox/pull/1456))
* [ispconfig_setup](https://github.com/servisys/ispconfig_setup)

## Other Scripts

### Datatype Information

Outputs C/C++ datatype information, including datatype sizes, minimum values, maximum values, etc. for the current system. Requires C++11. Supports Unix, including both Linux and macOS.

```bash
wget -qO - https://raw.github.com/tdulcet/Linux-System-Information/master/typeinfo.sh | bash -s
```

### Public IP addresses

Outputs your public IP addresses using a few dozen different services to find the one with the best HTTPS and DNS response times on your network.

```bash
wget -qO - https://raw.github.com/tdulcet/Linux-System-Information/master/ipinfo.sh | bash -s
```

## Other System Information Scripts

* [neofetch](https://github.com/dylanaraps/neofetch) (Supports multiple operating systems and Linux distributions, lots of command line options, outputs an ASCII version of the logo for a hard coded set of operating systems, but slow to run, displays less information, many of the features require external dependencies, a display and that it is run directly on the system and many of the features are disabled by default)
	* Test with this command:
```bash
wget -qO - https://raw.github.com/dylanaraps/neofetch/master/neofetch | bash -s -- -v --no_config
```
* [screenFetch](https://github.com/KittyKatt/screenFetch) (Supports multiple Linux distributions, lots of command line options, outputs an ASCII version of the logo for a hard coded set of distributions, but extremely slow to run and displays less information and many of the features require a display and that it is run directly on the system)
	* Test with this command:
```bash
wget -qO - https://raw.github.com/KittyKatt/screenFetch/master/screenfetch-dev | bash -s -- -v
```
* [system-report-card](https://github.com/swelljoe/system-report-card) (Only shows total RAM, swap and disk space)

## Contributing

Pull requests welcome! Ideas for contributions:

* Add more system information
	* Show SELinux status
	* Show the DNS Server
	* Show memory DDR type
* Add more examples
* Improve the performance
