kubectl delete configmap heketi-config
kubectl create configmap heketi-config --from-file=heketi.json --from-file=topology.json
