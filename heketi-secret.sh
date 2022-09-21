kubectl delete secret heketi-ssh-key-file
kubectl create secret generic heketi-ssh-key-file --from-file=/mnt/heketi/ssh/id_rsa
