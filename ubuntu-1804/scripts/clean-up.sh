#!/bin/bash

set -e -x

echo  "Removing machine-id, will be regenerated on next boot. Required by K8S."
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

rm /home/ubuntu/.ssh/authorized_keys

# Reset cloud-init for a fresh bootstrap
cloud-init clean --logs