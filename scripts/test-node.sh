#!/bin/bash

echo "Checking binaries"

for binary in kubeadm kubectl docker
do
    if [ -f /usr/bin/${binary} ]
    then
        echo "${binary}: ✓"
    else
        echo "${binary}: ❌"
    fi
done

echo "Checking that kubeadm init was successful"

kubectl --kubeconfig=/etc/kubernetes/admin.conf get nodes
