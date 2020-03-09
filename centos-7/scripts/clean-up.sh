#!/bin/bash

set -e -x

echo  "Removing machine-id, will be regenerated on next boot. Required by K8S."
truncate -s 0 /etc/machine-id

# Reset cloud-init for a fresh bootstrap
cloud-init clean --logs

rm /home/centos/.ssh/authorized_keys