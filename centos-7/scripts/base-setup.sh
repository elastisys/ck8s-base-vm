#!/bin/bash

set -e -x

# Disable swap and remove swap partititions
swapoff -a
cat /etc/fstab
blkid

# sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Install haveged to boost entropy pools in cloud environments
# See: https://www.digitalocean.com/community/tutorials/how-to-setup-additional-entropy-for-cloud-servers-using-haveged
yum install -y epel-release
yum install -y haveged rng-tools
systemctl enable haveged.service

# # Install volume mount support packages and SCTP support
yum update -y
yum install -y cifs-utils nfs-utils lksctp-tools

# # Reboot to cleanup swap files
shutdown -r