#!/bin/bash
# Clustom Install on Flatcar, 1 Node Cluster

IP=192.168.222.142
K3S_VERSION="v1.19.1+k3s1"
HELM_VERSION=v3.5.2
CERT_MGR_VERSION=v1.2.0
RANCHER_VERSION=2.5.5
INGRESS_DNS=core-server

# Install K3s 1 Node Cluster with ETCD
mkdir /opt/k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--write-kubeconfig ~/.kube/config --write-kubeconfig-mode 644 --tls-san ${IP} --cluster-init" INSTALL_K3S_BIN_DIR="/opt/k3s" INSTALL_K3S_VERSION=${K3S_VERSION} K3S_TOKEN="phWxL37@KREA" sh - 
sleep 90

# Get HELM
mkdir /opt/helm
cd /opt/helm
wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz
export PATH=$PATH:/opt/helm/linux-amd64:/opt/k3s

kubectl get pods --all-namespaces

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install Cert-Manager (for Let's Encrypt or Self-Signed autogenerated Keys)
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/${CERT_MGR_VERSION}/cert-manager.crds.yaml
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version ${CERT_MGR_VERSION}
kubectl -n cattle-system rollout status deploy/cert-manager

# Install Rancher
helm install rancher rancher-stable/rancher --version ${RANCHER_VERSION} --namespace cattle-system --create-namespace --set hostname=${INGRESS_DNS} --set replicas=1
kubectl -n cattle-system rollout status deploy/rancher
