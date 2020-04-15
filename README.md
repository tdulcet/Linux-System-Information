# Linux System Information
Linux System Information Script

Copyright © 2019 Teal Dulcet

Outputs system information on Linux, including:

* Linux distribution
* Computer Model
* Processor (CPU)
* CPU cores/threads
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

Useful when using an unfamiliar system or VM, particularly before running a program that has specific system requirements. All the values are saved to variables, which makes this easy to incorporate into larger scripts.

For your Public IP address and Hostname, please see [this page](https://gso.cs.pdx.edu/info/) (under "Command Line Interface (CLI)").

Please visit [tealdulcet.com](https://www.tealdulcet.com/) to support this script and my other software development.

Also see the [Linux System Usage Information](https://github.com/tdulcet/Linux-System-Information) script.

## Usage

Supports all modern Linux distributions and the [Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) (WSL).

### wget

```bash
wget https://raw.github.com/tdulcet/Linux-System-Information/master/info.sh -qO - | bash -s
```

### curl

```bash
curl https://raw.github.com/tdulcet/Linux-System-Information/master/info.sh | bash -s
```

## Example Output

### Ubuntu Desktop

![](images/Ubuntu%20Desktop.png)

### Ubuntu Server

![](images/Ubuntu%20Server.png)

### openSUSE Server

![](images/openSUSE%20Server.png)

### Raspberry Pi (Raspbian)

![](images/Raspberry%20Pi.png)

### Google Cloud Platform (Debian)

![](images/Google%20Cloud%20Platform.png)

## Scripts where this is incorporated

* [Linux Distributed Computing Scripts](https://github.com/tdulcet/Distributed-Computing-Scripts)
* [Mail-in-a-Box](https://github.com/mail-in-a-box/mailinabox) ([pending](https://github.com/mail-in-a-box/mailinabox/pull/1456))
* [ispconfig_setup](https://github.com/servisys/ispconfig_setup)

## Other System Information Scripts

* [neofetch](https://github.com/dylanaraps/neofetch) (Supports multiple operating systems and Linux distributions, lots of command line options, outputs an ASCII version of the logo for a hard coded set of operating systems, but slow to run, displays less information, many of the features require external dependencies, a display and that it is run directly on the system and many of the features are disabled by default)
	* Test with this command:
```bash
wget https://raw.github.com/dylanaraps/neofetch/master/neofetch -qO - | bash -s -- -v --no_config
```
* [screenFetch](https://github.com/KittyKatt/screenFetch) (Supports multiple Linux distributions, lots of command line options, outputs an ASCII version of the logo for a hard coded set of distributions, but extremely slow to run and displays less information and many of the features require a display and that it is run directly on the system)
	* Test with this command:
```bash
wget https://raw.github.com/KittyKatt/screenFetch/master/screenfetch-dev -qO - | bash -s -- -v
```
* [system-report-card](https://github.com/swelljoe/system-report-card) (Only shows total RAM, swap and disk space)

## Contributing

Pull requests welcome! Ideas for contributions:

* Add more system information
* Add more examples
* Improve the performance
