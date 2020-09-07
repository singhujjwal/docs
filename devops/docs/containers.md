# Containers

1. Docker
2. Containerd
3. rocket

[Container Runtime](https://www.ianlewis.org/en/container-runtimes-part-1-introduction-container-r)
OCI Open Container Interface - Standard for containers

## Docker
containerd(image management)-runc(runtime management)

docker daemon -> containerd -> runc

In K8s how docker and containerd works

kubelet <-CRI-> docker shim <-> docker <-> containerd <-> runc <-> container(s)

kubelet <-CRI-> cri-containerd <-> containerd <-> runc <-> container(s)

containerd
    - push and pull images
    - manage storage
    - define networks
    - managing lifecycle of running containers by passing commands to runc

runc
    - also known as libcontainer
    - low level run time
    - 
Rocket (rkt)
-- Dead

Linux containers (lxc & lxd)
VE vs VM running directly on the host VM

[More reading](https://www.inovex.de/blog/containers-docker-containerd-nabla-kata-firecracker/)
