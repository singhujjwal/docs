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

## Logs
There are various log files generated in Linux system which will help debugging the errors.

### journalctl 
journalctl is a command for viewing logs collected by systemd. The systemd-journald service is responsible for systemd’s log collection, and it retrieves messages from the kernel, systemd services, and other sources.

`journalctl -r`
`journalctl -u telegraf --no-pager -f` to see all the logs without paging and following the running logs

persist logs by making changes here /etc/systemd/journald.conf
