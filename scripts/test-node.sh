#!/bin/bash

set -e

echo "Checking binaries"

for binary in kubeadm kubectl docker
do
    if [ -f /usr/bin/${binary} ]
    then
        echo "${binary}: ✓"
    else
        echo "${binary}: ❌"
        exit 1
    fi
done

echo "Checking that kubeadm init was successful"

export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl cluster-info

# TODO: Install CNI if we want to test node actually becoming ready.
# ready=$(kubectl get nodes \
#         -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}')
# if [ "${ready}" != "True" ]; then
#     kubectl get nodes -o yaml
#     exit 1
# fi
if [ $(kubectl get nodes -o name | wc -l) -ne 1 ]; then
    echo "Expected 1 node" >&2
    exit 1
fi
