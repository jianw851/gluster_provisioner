# installation 

## create directory

```
mkdir -p /data/heketi/{db,.ssh} && chmod 700 /data/heketi/.ssh

```

## generate heketi ssh keys that will be used by heketi api for password-less login to glusterfs servers

```
 this does't work after OpenSSH 7.0  ssh-keygen -t rsa -b 2048 -f /mnt/heketi/.ssh/id_rsa

use the following line
ssh-keygen -m PEM -t rsa -b 4096 -q -f /mnt/heketi/.ssh/id_rsa -N ''
```

## copy .ssh dir to all glusterfs servers

```
for node in node1 node2 node3; do scp -r /mnt/heketi/.ssh root@${node}:/mnt/heketi; done
```

## import ssh public key to all servers

```
cat /mnt/heketi/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
```

## create a kubernetes secret to store ssh private key

```
kubectl create secret generic heketi-ssh-key-file \
  --from-file=/mnt/heketi/.ssh/id_rsa
```

## create heketi.json file

```
{
  "_port_comment": "Heketi Server Port Number",
  "port": "8080",
  "_use_auth": "Enable JWT authorization.",
  "use_auth": true,
  "_jwt": "Private keys for access",
  "jwt": {
    "_admin": "Admin has access to all APIs",
    "admin": {
      "key": "ADMIN-HARD-SECRET"
    }
  },
  "_glusterfs_comment": "GlusterFS Configuration",
  "glusterfs": {
    "executor": "ssh",
    "_sshexec_comment": "SSH username and private key file",
    "sshexec": {
      "keyfile": "/heketi/heketi-ssh-key",
      "user": "root",
      "port": "22"
    },
    "_db_comment": "Database file name",
    "db": "/var/lib/heketi/heketi.db",
    "loglevel" : "debug"
  }
}
```


