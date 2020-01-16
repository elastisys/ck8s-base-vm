#!/bin/bash

set -e -x

kubeadm config images pull
kubeadm init