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
  
# setup /etc/hosts with right names
  
cat << EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sudo sysctl --system
  
#install containerd
sudo apt-get update && sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo systemctl restart containerd
  
sudo swapoff -a
sudo vi /etc/fstab


sudo sysctl --system
# On all nodes
  
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat << EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet=1.23.0-00 kubeadm=1.23.0-00 kubectl=1.23.0-00 sudo apt-mark hold kubelet kubeadm kubectl
  
#Only on master

sudo kubeadm init --pod-network-cidr 192.168.0.0/16 --kubernetes-version 1.23.0
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl get nodes
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
  
kubeadm token create --print-join-command  
  
# on all worker nodes  
sudo kubeadm join ...
  

kubectl get nodes
```

## Securing Persistent Key Value Store or SECRETS in k8s
`kubectl get secrets`
`kubectl run pod-with-defaults --image alpine --restart Never -- /bin/sleep 999999`
`kubectl describe pods pod-with-defaults`
`kubectl exec pod id`
```
kubectl describe secret
openssl genrsa -out https.key 2048
openssl req -new -x509 -key https.key -out https.cert -days 3650 -subj /CN=www.example.com
touch file
kubectl create secret generic example-https --from-file=https.key --from-file=https.cert --from-file=file
kubectl get secrets example-https -o yaml
```

`nginx.conf` ConfigMap

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: config
data:
  my-nginx-config.conf: |
    server {
        listen              80;
        listen              443 ssl;
        server_name         www.example.com;
        ssl_certificate     certs/https.cert;
        ssl_certificate_key certs/https.key;
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         HIGH:!aNULL:!MD5;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

    }
  sleep-interval: |
    25
```

`example-https.yaml`
```

apiVersion: v1
kind: Pod
metadata:
  name: example-https
spec:
  containers:
  - image: linuxacademycontent/fortune
    name: html-web
    env:
    - name: INTERVAL
      valueFrom:
        configMapKeyRef:
          name: config
          key: sleep-interval
    volumeMounts:
    - name: html
      mountPath: /var/htdocs
  - image: nginx:alpine
    name: web-server
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
      readOnly: true
    - name: config
      mountPath: /etc/nginx/conf.d
      readOnly: true
    - name: certs
      mountPath: /etc/nginx/certs/
      readOnly: true
    ports:
    - containerPort: 80
    - containerPort: 443
  volumes:
  - name: html
    emptyDir: {}
  - name: config
    configMap:
      name: config
      items:
      - key: my-nginx-config.conf
        path: https.conf
  - name: certs
    secret:
      secretName: example-https

```

`kubectl exec example-https -c web-server -- mount | grep certs`
`kubectl port-forward example-https 8443:443 &`
`curl https://localhost:8443 -k`

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


