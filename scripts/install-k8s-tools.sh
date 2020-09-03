#!/bin/bash

set -e -x

: "${KUBELET_VERSION:?Missing KUBELET_VERSION}"
: "${KUBEADM_VERSION:?Missing KUBEADM_VERSION}"
: "${KUBECTL_VERSION:?Missing KUBECTL_VERSION}"

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y \
    kubelet="${KUBELET_VERSION}" \
    kubeadm="${KUBEADM_VERSION}" \
    kubectl="${KUBECTL_VERSION}"
# Support nfs-provisioner and Falco
apt-get install -y nfs-common linux-headers-$(uname -r)
apt-mark hold kubelet kubeadm kubectl

# Prepare images required for setting up a Kubernetes cluster.
# Not needed on worker nodes, hopefully garbage collected eventually.
kubeadm config images pull \
    --kubernetes-version "$(kubelet --version | awk '{print $2}')"
# Pull images for latest version as well to speed up upgrades.
kubeadm config images pull
