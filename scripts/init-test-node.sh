#!/bin/bash

set -e -x

kubeadm init --kubernetes-version "$(kubelet --version | awk '{print $2}')"
