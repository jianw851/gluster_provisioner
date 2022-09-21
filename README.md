# Steps to install gluster cluster on on-prem k8s

## 1. install gluster server on all storage nodes

```
apt install -y glusterfs-server
systemctl enable --now glusterd.service
gluster peer probe <2nd node hostname>
gluster peer probe <3rd node hostname>
gluster volume create k8s-volume replica 2 arbiter 1 transport tcp \
  <node 2>: /gluster/volume \
  <node 3>: /gluster/volume \


gluster volume info k8s-volume
```

## 2. prepare kubernetes worker nodes

```
apt install glusterfs-client
```


## 3. discovering glusterfs in kubernetes

```
apiVersion: v1
kind: Endpoints
metadata:
  name: glusterfs-cluster
  labels:
    storage.k8s.io/name: glusterfs
    storage.k8s.io/created-by: xxxx
subsets:
  - addresses:
      - ip: xxx.xxx.xxx.xxx
        hostname: master
      - ip: xxx.xxx.xxx.xxx
        hostname: live1
      - ip: xxx.xxx.xxx.xxx
        hostname: live2
    ports:
      - port: 1
```

## 4. using glusterfs in kubernetes


### 4.1 using glusterfs by specifying endpoint

```
apiVersion: v1
kind: Pod
metadata:
  name: test
  labels:
    app.kubernetes.io/name: hostname
    app.kubernetes.io/created-by: xxx 
spec:
  containers:
    - name: alpine
      image: alpine:latest
      command:
        - touch
        - /data/test
      volumeMounts:
        - name: glusterfs-volume
          mountPath: /data
  volumes:
    - name: glusterfs-volume
      glusterfs:
        endpoints: glusterfs-cluster
        path: k8s-volume
        readOnly: no
```

### 4.2 using glusterfs by persistentvolume

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: glusterfs-volume
  labels:
    storage.k8s.io/name: hostname
    storage.k8s.io/created-by: xxx
spec:
  accessModes:
    - ReadWriteOnce
    - ReadOnlyMany
    - ReadWriteMany
  capacity:
    storage: 10Gi
  storageClassName: ""
  persistentVolumeReclaimPolicy: Recycle
  volumeMode: Filesystem
  glusterfs:
    endpoints: glusterfs-cluster
    path: k8s-volume
    readOnly: no
```


### 4.3 dynamic provisioning using storageclass


#### 4.3.1 create a volume using glusterfs

```
gluster volume create heketi-db-volume replica 3 transport tcp \
  master:/mnt/heketi/db \
  live1:/mnt/heketi/db \
  live2:/mnt/heketi/db force

gluster volume start heketi-db-volume
```

#### 4.3.2 Please follow the installation guide for heketi

#### 4.3.3 load topology file

```
kubectl exec POD-NAME -- heketi-cli \
  --user admin \
  --secret ADMIN-HARD-SECRET \
  topology load --json /etc/heketi/topology.json
```


#### 4.3.4 test if can get the cluster id from heketi

```
kubectl exec POD-NAME -- heketi-cli \
  --user admin \
  --secret ADMIN-HARD-SECRET \
  cluster list
Clusters:
Id:c63d60ee0ddf415097f4eb82d69f4e48 [file][block]
```
