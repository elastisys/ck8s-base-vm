#!/bin/bash

set -e -x


: "${KUBERNETES_VERSION:?Missing KUBERNETES_VERSION}"

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y \
    kubelet="${KUBERNETES_VERSION}" \
    kubeadm="${KUBERNETES_VERSION}" \
    kubectl="${KUBERNETES_VERSION}"
# Support nfs-provisioner and Falco
apt-get install -y nfs-common linux-headers-$(uname -r)
apt-mark hold kubelet kubeadm kubectl
