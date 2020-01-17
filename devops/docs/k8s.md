# Kubernetes Concepts and Learnings

## Concepts
K8s objects are record of intent. Once you create it the kubernetes system takes care of making sure it is running all the time.
Object spec: What is constitutes
Object Status: Makes sure the status of the objects remains the same as defined in the status.

### Pod
A pod represents a running process on your  system sharing the same network (port and ip), storage. 
A pod enacapsulates an applicaton running in one or more containers, pods itself doesn’t heal, 
will need a deployment to get the self healing capability.

### Services
A Kubernetes Service is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called a micro-service. The set of Pods targeted by a Service is (usually) determined by a Label Selector (see below for why you might want a Service without a selector).
As an example, consider an image-processing backend which is running with 3 replicas. Those replicas are fungible - frontends do not care which backend they use. While the actual Pods that compose the backend set may change, the frontend clients should not need to be aware of that or keep track of the list of backends themselves. The Service abstraction enables this decoupling.

Kubernetes also supports DNS SRV (service) records for named ports. If the "my-service.my-ns" Service has a port named "http" with protocol TCP, you can do a DNS SRV query for "_http._tcp.my-service.my-ns" to discover the port number for "http".
The Kubernetes DNS server is the only way to access services of type ExternalName

Kubernetes ServiceTypes allow you to specify what kind of service you want. The default is ClusterIP.
Type values and their behaviors are:

1. ClusterIP: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster. This is the default ServiceType.
2. NodePort: Exposes the service on each Node’s IP at a static port (the NodePort). A ClusterIP service, to which the NodePort service will route, is automatically created. You’ll be able to contact the NodePort service, from outside the cluster, by requesting <NodeIP>:<NodePort>.
3. LoadBalancer: Exposes the service externally using a cloud provider’s load balancer. NodePort and ClusterIP services, to which the external load balancer will route, are automatically created.
4. ExternalName: Maps the service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value. No proxying of any kind is set up. This requires version 1.7 or higher of kube-dns.


### Commands
Print the kubelet joinging command:
sudo kubeadm token create --print-join-command
kubelet reset # to reset a node joined to a master, also from master it can be deleted like kubectl delete node <node-name>

```bash
https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/

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

## Helm

Package manager for kubernetes
Helm runs with "default" service account. You should provide permissions to it.
For read permissions:
kubectl create rolebinding default-view --clusterrole=view --serviceaccount=kube-system:default --namespace=kube-system

For admin permissions:
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default

More details here
https://stackoverflow.com/questions/46672523/helm-list-cannot-list-configmaps-in-the-namespace-kube-system



## Cert-Manager

Cert manager is a very important package for generating certs for applications in k8s.
DNS01 challenge are very helpful in creating wildcard certificates, also http01 challenges are good when you want just few certs
There are many gotchas and need to have either a role, cross account role for AWS
For azure use the service principal.
Also for split horizon dns cert-manager can be run using parameter `extraArgs={--dns01-recursive-nameservers "8.8.8.8:53,1.1.1.1:53"}’
https://cert-manager.io/docs/configuration/acme/dns01/

Steps to use cert-manager
1.	Install cert-manager CRDS
2.	Install cert-manager with the extra dns options in case of split horizon or delegated DNS
3.	Create a certificate issuer in cert-manager namespace based on the CRD

apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
  namespace: cert-manager
spec:
  acme:
    # server: https://acme-staging-v02.api.letsencrypt.org/directory
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ujjwal.singh@halliburton.com
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - selector:
        dnsZones:
            - "tenant1.landmarksoftware.io"
      dns01:
        route53:
            region: us-east-1
            hostedZoneID: xxxxxxxxxxxx
            role: 'arn:aws:iam::xxxxxxxxxx:role/Gitlab-Runner'



4.	Create the certificate in the namespace where you want to use the tls secret, else you need to copy the tls secret to all the namespaces if  the ingress needs to be created in another namespace
apiVersion: cert-manager.io/v1alpha2
kind: Certificate
metadata:
  name: lets-encrypt-cert
  namespace: ict
spec:
  commonName: 'ujjwal.tenant1.landmarksoftware.io'
  dnsNames:
  - '*.ujjwal.tenant1.landmarksoftware.io'
  - 'ujjwal.tenant1.landmarksoftware.io'
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-staging
  secretName: letsencrypt-staging-cert-secret



5.	Create an ingress which loads the tls certs 
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
  - host: ujjwal.tenant1.landmarksoftware.io
    http:
      paths:
        - path: /awx
          backend:
            serviceName: awx
            servicePort: 8052 # The node port

6.	You can use https://github.com/mittwald/kubernetes-replicator for replicating secrets across namespaces.




