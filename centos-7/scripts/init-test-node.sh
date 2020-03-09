#!/bin/bash

set -e -x

# systemctl enable docker
# systemctl start docker

# while true; do
#   if [ $(systemctl is-active docker) == "active" ]; then
#     break
#   fi
#     sleep 1
# done

# systemctl enable kubelet
# systemctl start kubelet

# while true; do
#   if [ $(systemctl is-active kubelet) == "active" ]; then
#     break
#   fi
#     sleep 1
# done

kubeadm config images pull
kubeadm init
