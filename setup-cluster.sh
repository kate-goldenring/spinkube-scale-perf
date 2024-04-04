#! /bin/bash

set -euox

SHIM_VERSION=${1:-v0.13.1}

sudo snap install microk8s --classic

microk8s status --wait-ready
microk8s enable dns helm3 rbac

alias kubectl='microk8s kubectl'
alias helm='microk8s helm3'

# Apply Spin runtime class
kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.1.0/spin-operator.runtime-class.yaml

# Apply Spin CRDs
kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.1.0/spin-operator.crds.yaml

# Install cert-manager CRDs
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.crds.yaml

# Add and update Jetstack repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install the cert-manager Helm chart
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.14.3

# Wait for cert-manager to be ready
kubectl wait --for=condition=available --timeout=20s deployment/cert-manager-webhook -n cert-manager

# Add Helm repository if not already done
helm repo add kwasm http://kwasm.sh/kwasm-operator/

# Install KWasm operator
helm install \
  kwasm-operator kwasm/kwasm-operator \
  --namespace kwasm \
  --create-namespace \
  --set "kwasmOperator.installerImage=ghcr.io/spinkube/containerd-shim-spin/node-installer:$SHIM_VERSION"

# Re-export kubeconfig as kwasm operator may restart the process 
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Provision Nodes
kubectl annotate node --all kwasm.sh/kwasm-node=true

# Install Spin Operator with Helm
helm install spin-operator \
  --namespace spin-operator \
  --create-namespace \
  --version 0.1.0 \
  --wait \
  oci://ghcr.io/spinkube/charts/spin-operator

# Add the shim executor for the Spin operator
kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.1.0/spin-operator.shim-executor.yaml

# Wait for the Spin Operator to be ready
kubectl wait --for=condition=available --timeout=20s deployment/spin-operator-controller-manager -n spin-operator

