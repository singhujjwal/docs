# Kubernetes Concepts

## Concepts
The best resource for learning kubernetes concepts is the kubernetes reference docs. I will try to be concise here
and will be mostly including relevant links as managing those links in the bookmarks folder becomes unmanageable
and putting the duplicate material is a waste of time and doesnt give the due respect to the original authors.
[Concepts](https://kubernetes.io/docs/concepts)

I will be putting stuffs down, which I think I keep forgetting 

A loadbalancer is exteneded type of nodeport service where an external loadbalancer is created based on the cloud provider.
A loadbalancer will have a port mapping for the port LB is listening to the target port and the service name
Tcp can be patched to the nginx ingress controller loadbalancer by creating a config map and telling where in which namespace which service on which port to hit.
e.g. 

```yaml

apiVersion: v1
kind: Service
metadata:
  name: tcp-echo
  labels:
    app: tcp-echo
spec:
  ports:
  - name: tcp
    port: 9000
  selector:
    app: tcp-echo
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tcp-echo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tcp-echo
      version: v1
  template:
    metadata:
      labels:
        app: tcp-echo
        version: v1
    spec:
      containers:
      - name: tcp-echo
        image: docker.io/istio/tcp-echo-server:1.1
        imagePullPolicy: IfNotPresent
        args: [ "9000", "hello" ]
        ports:
        - containerPort: 9000


```
Below created the config map nginx-ingress-tcp while creating nginx load balancer

--set tcp.9000="my-system/tcp-echo:9000" \

Also you can have now mostly all internal load balancers and for external load balancers use WAF for better security
the WAF will be communicating with the internal load balancers and will figure out how TLS/SSL certificates now
work in addition to cert-manager.

### Volumes

- Types of volumes
    * Local
    * EBS
    * azureDisk
    * azureFile
    * configMap
    * emptyDir
    * hostPath
    * local
    * nfs
    * persistentVolumeClaim

#### Persistent Volume
A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes. It is a resource in the cluster just like a node is a cluster resource. PVs are volume plugins like Volumes, but have a lifecycle independent of any individual Pod that uses the PV. This API object captures the details of the implementation of the storage, be that NFS, iSCSI, or a cloud-provider-specific storage system.

#### Persistent Volume Claim

A PersistentVolumeClaim (PVC) is a request for storage by a user. It is similar to a Pod. Pods consume node resources and PVCs consume PV resources. Pods can request specific levels of resources (CPU and Memory). Claims can request specific size and access modes (e.g., they can be mounted once read/write or many times read-only).
It can be static of dynamic, if a cluster admin has not created a PV explicitly a dynamic PV is created when a PVC is requested.

### Few Commands
Print the kubelet joinging command:
sudo kubeadm token create --print-join-command
kubelet reset # to reset a node joined to a master, also from master it can be deleted like kubectl delete node <node-name>

```bash
# https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/

kubectl port-forward pods/redis-master-765d459796-258hz 6379:6379
or
kubectl port-forward deployment/redis-master 6379:6379 
or
kubectl port-forward rs/redis-master 6379:6379 
or
kubectl port-forward svc/redis-master 6379:6379
```

## K8s Install on CENTOS

```bash
sudo swapoff -a
sudo vi /etc/fstab
sudo yum -y install docker
sudo systemctl enable docker
sudo systemctl start docker
cat << EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo setenforce 0
sudo vi /etc/selinux/config
# Change to permissive
sudo yum install -y kubelet kubeadm kubectl
sudo systemctl enable kubelet
sudo systemctl start kubelet
cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

sudo sysctl --system

#Only on master
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml

# only on worker nodes
sudo kubeadm join $controller_private_ip:6443 --token $token --discovery-token-ca-cert-hash $hash

sudo kubeadm join 172.31.100.147:6443 --token w28oiv.2dx6buwbj400mc4x --discovery-token-ca-cert-hash sha256:ed0e354f71183a76cbb58166d5d710b3b39e343c253ee232509ce5f412d05b3a

kubectl get nodes
```
## Cert-Manager

Cert manager is a very important package for generating certs for applications in k8s.
DNS01 challenge are very helpful in creating wildcard certificates, also http01 challenges are good when you want just few certs
There are many gotchas and need to have either a role, cross account role for AWS
For azure use the service principal.
Also for split horizon dns cert-manager can be run using parameter 
`extraArgs={--dns01-recursive-nameservers "8.8.8.8:53,1.1.1.1:53"}`

https://cert-manager.io/docs/configuration/acme/dns01/


Steps to use cert-manager
1.	Install cert-manager CRDS
2.	Install cert-manager with the extra dns options in case of split horizon or delegated DNS
3.	Create a certificate issuer in cert-manager namespace based on the CRD

```yaml
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
  namespace: cert-manager
spec:
  acme:
    # server: https://acme-staging-v02.api.letsencrypt.org/directory
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ujjwal.singh@example.com
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - selector:
        dnsZones:
            - "tenant1.example.com"
      dns01:
        route53:
            region: us-east-1
            hostedZoneID: xxxxxxxxxxxx
            role: 'arn:aws:iam::xxxxxxxxxx:role/Role-DNS-STS'
```


4.	Create the certificate in the namespace where you want to use the tls secret, else you need to copy the tls secret to all the namespaces if  the ingress needs to be created in another namespace

```yaml
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: lets-encrypt-cert
  namespace: ict
spec:
  commonName: 'ujjwal.tenant1.example.com'
  dnsNames:
  - '*.ujjwal.tenant1.example.com'
  - 'ujjwal.tenant1.example.com'
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-staging
  secretName: letsencrypt-staging-cert-secret
```


5.	Create an ingress which loads the tls certs 
```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: traefik-ingress
  namespace: ict
  annotations:
    kubernetes.io/ingress.class: traefik
spec:
  tls:
    - secretName: letsencrypt-staging-cert-secret
  rules:
  - host: ujjwal.tenant1.example.com
    http:
      paths:
        - path: /awx
          backend:
            serviceName: awx
            servicePort: 8052 # The node port
```
6.	You can use https://github.com/mittwald/kubernetes-replicator for replicating secrets across namespaces.


