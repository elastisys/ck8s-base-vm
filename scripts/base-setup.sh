#!/bin/bash

set -e -x

# Wait for boot to finish
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done

# Disable unattended upgrades
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic
cat << END >> /etc/apt/apt.conf.d/51-disable-unattended-upgrades
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

# Also disable timers from factory settings to prevent re-enabling when systemd is reset
# and reloads factory presets e.g. after /etc/machine-id is removed
cat << END >> /lib/systemd/system-preset/10-disable-unattended-upgrades
disable apt-daily.timer
disable apt-daily-upgrade.timer
END

# Add CloudStack cloud-init datasource, required by Exoscale for cloud-init enabled images
cat << END >> /etc/cloud/cloud.cfg.d/99_exoscale.cfg
datasource:
  CloudStack: {}
  None: {}
datasource_list:
  - CloudStack
END
