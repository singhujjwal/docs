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

