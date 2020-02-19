# Kubernetes Concepts

## Concepts
K8s objects are record of intent. Once you create it the kubernetes system takes care of making sure it is running all the time.
Object spec: What is constitutes
Object Status: Makes sure the status of the objects remains the same as defined in the status.

### Pod

A pod represents a running process on your  system sharing the same network (port and ip), storage. 
A pod enacapsulates an applicaton running in one or more containers, pods itself doesn’t heal, 
will need a deployment to get the self healing capability.

### Services
A Kubernetes Service is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called a micro-service. The set of Pods targeted by a Service is (usually) determined by a Label Selector.


Kubernetes also supports DNS SRV (service) records for named ports. If the "my-service.my-ns" Service has a port named "http" 
with protocol TCP, you can do a DNS SRV query for "_http._tcp.my-service.my-ns" to discover the port number for "http".
The Kubernetes DNS server is the only way to access services of type ExternalName

Kubernetes ServiceTypes allow you to specify what kind of service you want. The default is ClusterIP.
Type values and their behaviors are:

1. ClusterIP: Exposes the service on a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster. This is the default ServiceType.
2. NodePort: Exposes the service on each Node’s IP at a static port (the NodePort). A ClusterIP service, to which the NodePort service will route, is automatically created. You’ll be able to contact the NodePort service, from outside the cluster, by requesting <NodeIP>:<NodePort>.
3. LoadBalancer: Exposes the service externally using a cloud provider’s load balancer. NodePort and ClusterIP services, to which the external load balancer will route, are automatically created.
4. ExternalName: Maps the service to the contents of the externalName field (e.g. foo.bar.example.com), by returning a CNAME record with its value. No proxying of any kind is set up. This requires version 1.7 or higher of kube-dns.


### Volumes
Types of volumes
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
  
Example of AWS EBS
1.  Create a volume first in the same zone as the node is present using command `aws ec2 create-volume --availability-zone=eu-west-1a --size=10 --volume-type=gp2`
2.  Use the below YAML to provide and ebs volume to a pod

```yaml
  apiVersion: v1
  kind: Pod
  metadata:
    name: test-ebs
  spec:
    containers:
    - image: k8s.gcr.io/test-webserver
      name: test-container
      volumeMounts:
      - mountPath: /test-ebs
        name: test-volume
    volumes:
    - name: test-volume
      # This AWS EBS volume must already exist.
      awsElasticBlockStore:
        volumeID: <volume-id>
        fsType: ext4
```
4. configMap is one of the very frequently used volume which is basically a key value store [details](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
    - name: test
      image: busybox
      volumeMounts:
        - name: config-vol
          mountPath: /etc/config
  volumes:
    - name: config-vol
      configMap:
        name: log-config
        items:
          - key: log_level
            path: log_level
```

5.  projected : A projected volume maps several existing volume sources into the same directory. [e.g.](https://kubernetes.io/docs/concepts/storage/volumes/#projected)

#### Persistent Volume
A PersistentVolume (PV) is a piece of storage in the cluster that has been provisioned by an administrator or dynamically provisioned using Storage Classes. It is a resource in the cluster just like a node is a cluster resource. PVs are volume plugins like Volumes, but have a lifecycle independent of any individual Pod that uses the PV. This API object captures the details of the implementation of the storage, be that NFS, iSCSI, or a cloud-provider-specific storage system.

#### Persistent Volume Claim

A PersistentVolumeClaim (PVC) is a request for storage by a user. It is similar to a Pod. Pods consume node resources and PVCs consume PV resources. Pods can request specific levels of resources (CPU and Memory). Claims can request specific size and access modes (e.g., they can be mounted once read/write or many times read-only).
It can be static of dynamic, if a cluster admin has not created a PV explicitly a dynamic PV is created when a PVC is requested.

#### Storage Class



## Ingress
### NGINX Ingress controller
#### Exposing TCP port 
You can expose a TCP port from an ingress-controller directly to outside world. It can be done by installing nginx with a `nginx-ingress-tcp` config map.
It gets created and USED only when is nginx is installed or upgraded # TBD come and revisit

so do a helm install `--set tcp.9000="plat-system/tcp-echo:9000"` with this or else
`helm upgrade` with all existing options and the above.
After that patch the configmap and the nginx service

ConfigMap as `configmap.yaml`

```yaml
data:
  "31000": namespace/service:31000
```

`kubectl patch configmaps nginx-ingress-tcp --namespace namespace --patch "$(cat configmap.yaml)"`

Service patch as ` service.yaml`

```yaml
spec:
  ports:
  - name: service-31000
    port: 31000
    protocol: TCP
    targetPort: 31000
```
As you can see name `service-31000` doesn't matter.


`kubectl patch services nginx-ingress-controller --namespace namespace --patch "$(cat service.yaml)"`





