# Linux System Information
Linux System Information Script

Copyright © 2019 Teal Dulcet

Outputs system information on Linux, including:

* Linux distribution
* Processor (CPU)
* CPU cores/threads
* Architecture
* Total memory (RAM) in MiB (1024<sup>2</sup> bytes) and MB (1000<sup>2</sup> bytes)
* Total swap space in MiB (1024<sup>2</sup> bytes) and MB (1000<sup>2</sup> bytes)
* \*Graphics Processor (GPU)
* Hostname
* IP address(es)
* Time zone
* Language
* \*Virtualization container
* \*Virtual Machine (VM) hypervisor

\* If present

Useful when using an unfamiliar system or VM, particularly before running a program that has specific system requirements. All the values are saved to variables, which makes this easy to incorporate into larger scripts. Supports all modern Linux distributions and the [Windows Subsystem for Linux](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) (WSL).

If you are looking for your Public IP address and Hostname, please see [this page](https://gso.cs.pdx.edu/info/) (under "Command Line Interface (CLI)").

## Usage

### wget

```bash
wget https://raw.github.com/tdulcet/Linux-System-Information/master/info.sh -qO - | bash -s --
```

### curl

```bash
curl https://raw.github.com/tdulcet/Linux-System-Information/master/info.sh | bash -s --
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

* [system-report-card](https://github.com/swelljoe/system-report-card) (Only shows total RAM, swap and disk space)

## Contributing

Pull requests welcome! Ideas for contributions:

* Add more system information
* Add more examples
* Improve the performance
