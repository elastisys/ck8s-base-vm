#!/bin/bash

set -e -x

: "${CONTAINERD_VERSION:?Missing CONTAINERD_VERSION}"
: "${DOCKER_VERSION:?Missing DOCKER_VERSION}"

# Following the official K8S docs: https://kubernetes.io/docs/setup/production-environment/container-runtimes/

# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get update
apt-get install -y \
  apt-transport-https ca-certificates curl gnupg-agent software-properties-common

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository.
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install Docker CE.
apt-get update
apt-get install -y \
  containerd.io="${CONTAINERD_VERSION}" \
  docker-ce="${DOCKER_VERSION}" \
  docker-ce-cli="${DOCKER_VERSION}"

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl enable docker
systemctl restart docker
