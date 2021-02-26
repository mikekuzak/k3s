!#/bin/bash

# Uninstall Rancher
helm delete rancher -n cattle-system
kubectl delete namespaces cattle-system

# Uninstall K3s
/opt/k3s/k3s-uninstall.sh
