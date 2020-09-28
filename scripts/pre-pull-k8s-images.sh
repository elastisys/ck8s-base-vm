# Prepare images required for setting up a Kubernetes cluster.
# Not needed on worker nodes, hopefully garbage collected eventually.
kubeadm config images pull \
    --kubernetes-version "$(kubelet --version | awk '{print $2}')"
# Pull images for latest version as well to speed up upgrades.
kubeadm config images pull
