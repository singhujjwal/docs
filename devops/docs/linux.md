

# Bash Scripting
## Update code present 
* Command to pull all the code from master branch in all the subdirectories in a code folder

```bash
for d in $(find -maxdepth 1 -type d) 
do 
  pushd $d 
  git pull 
  popd 
done 
```

# Setting proxy for updates
## Ubuntu

`cat /etc/apt/apt.conf`

```bash
Acquire::http::Proxy  "http://proxy.example.com:80";
Acquire::ftp::Proxy   "https://proxy.example.com:80";
Acquire::https::Proxy "http://proxy.example.com:80";
```

# Troubleshooting
## Networking 
use either telnet or ncat

nc -vvvzw1 google.com 443
nc is part of bind tools


wget https://github.com/tmate-io/tmate/releases/download/2.4.0/tmate-2.4.0-static-linux-amd64.tar.xz
chmod +x ./tmate 
xz -cd te-2.4.0-static-linux-amd64.tar.xz | t 
./tmate -F


# Linux Debugging
Linux debugging is nothing without knowing the right commands. That too in quick time. Debugging Linux falls into various categories
* System diagnostics: Devices, CPU, memory, IO, networking
* Logs
* Processes
* Inspecting filesystem and open files
* Sockets and networking 
*


## System Diagonostics
* top
* mpstat
* sar # install using apt-get install sysstat
    Cron job present here `cat /etc/cron.d/sysstat`
    sar between 10AM-12 AM `sar -r -s 10:00:00 -e 12:00:00`
    sar on 10th of the month `sar -f /var/log/sysstat/sa10 -b`

## Logs
There are various log files generated in Linux system which will help debugging the errors.

### journalctl 
journalctl is a command for viewing logs collected by systemd. The systemd-journald service is responsible for systemd’s log collection, and it retrieves messages from the kernel, systemd services, and other sources.

`journalctl -r`
`journalctl -u telegraf --no-pager -f` to see all the logs without paging and following the running logs

persist logs by making changes here /etc/systemd/journald.conf
