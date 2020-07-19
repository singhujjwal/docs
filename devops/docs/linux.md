# COMMON
##  Commands
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
* 
# Centos
## Mounting NFS volumes

`mount -o rsize=32768,wsize=32768,noatime,intr <ip-address>:<export-path> <mnt-point>`
`mkdir /mnt/myvol01`

`mount -o rsize=32768,wsize=32768,noatime,intr 10.22.197.195:/export/pool1/ujjwalvol /mnt/vol01`

Make entry in /etc/fstab for permanent

`10.22.197.195:/export/pool1/ujjwalvol /mnt/vol01 nfs rw,hard,intr,rsize=32768,wsize=32768,timeo=14 0 0`

After making changes in `/etc/fstab` need to mount the directory as `mount /mnt/vol01/` and you 
don't need to restart the machine neither nfs not linux

Common NFS Issues
The most common issue encountered when mounting and using an NFS volume are Access Denied and read-only types of problems.
 
Access Denied - This typically happens when trying to mount an NFS export that has been restricted by IP address range, user ID or other permission restrictions. Try opening up the NFS export for access by any IP address and Everyone; i.e., loosen the security up during initial testing, then lock it back down one step at a time.
 
Read-Only Access - When this happens, it is possible to mount the filesystem, but not possible to write to the mounted filesystem. This is a security permissions issue. Try opening up the permissions on the NFS export to Everyone as a starting point, then with a working NFS mount, choose to lock the security down incrementally.


# Ubuntu

## Setting proxy in ubuntu for update

`cat /etc/apt/apt.conf`

```bash
Acquire::http::Proxy  "http://proxy.example.com:80";
Acquire::ftp::Proxy   "https://proxy.example.com:80";
Acquire::https::Proxy "http://proxy.example.com:80";
```

## Setting up docker

## Upgrading python

`sudo apt install python3.8`


`sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1`
`sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.7 2`

`sudo update-alternatives --config python3`

Install pip
`sudo apt install python3-pip`
