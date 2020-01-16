#!/bin/bash

set -e -x

# Disable unattended upgrades
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic
cat << END >> /etc/apt/apt.conf.d/51disable-unattended-upgrades
APT::Periodic::Enable "0";
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::Unattended-Upgrade "0";
END

# Disable the timers triggering unattended upgrades
systemctl stop apt-daily.timer
systemctl disable apt-daily.timer
systemctl stop apt-daily-upgrade.timer
systemctl disable apt-daily-upgrade.timer

# Disable swap and remove swap partititions
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Reboot to cleanup swap files
shutdown -r