kubectl create secret generic heketi-admin-secret \
  --type=kubernetes.io/glusterfs \
  --from-literal=key=<adminsecretkey>
