# ck8s-base-vm

Base image for K8S nodes (Ubuntu 18.04 LTS).


## Overview

Create a QEMU base VM image using Packer to be used as a starter kit to deploy Kubernetes nodes, built on top of Ubuntu 18.04 LTS.

What's inside:

* docker-ce (with systemd cgroup driver)
* containerd
* kubeadm
* kubelet
* kubectl
* cloud-init

Unattended updates have been disabled and all K8S package versions are pinned to their released versions at the time of build.


## Building the image

Pre-requisites:

* Packer 1.5+ (https://www.packer.io/downloads.html)
* KVM (https://help.ubuntu.com/community/KVM/Installation)

Build steps:

1. Clone the repo and move to its directory.
2. Build the image: `$ make build`.
3. Run tests: `$ make test`.
4. Check `output-baseos` for the built qcow2 image and its associated checksum file.
5. If you need to rebuild, first run `make clean` to remove all files created during previous builds.


## Notes

* Check `baseos-build.log` file for build related logs or `baseos-build.log` file for test related logs.
* The tests use a backing image on top of the tested image in order to avoid altering the built artefact.
* The compliance tests are very basic: included are checks for required binaries (docker, kubeadm etc.) and checks that kubeadm init is successful.
  Note that you will need to check the log for these results!
* Known issue: relative path to checksum does not work (see https://github.com/hashicorp/packer/issues/9047)


## Troubleshooting


### Packer qemu builder cannot access KVM kernel module.

Make sure the user you are running as is a member of `kvm` group:
`sudo usermod -aG kvm $(whoami) && sudo reboot`

### I need to change the SSH password before provisioning a VM instance or in the build plan.

In order to deploy the VM with a secure password, modify/extend the cloud-init configuration in `./cloud-init/baseos/user-data`.

Generate a new SHA-512 hashed password via: `mkpasswd --method=SHA-512 --rounds=4096 PASSWORD`

If you need to rebuild with a different password, also edit the `ssh_username` and `ssh_password` values in the top variables block from `./baseos.json`.

### I need to access the built VM for debugging.

During build, Packer is configured to expose a VNC access endpoint at 127.0.0.1:5900. Use any VNC client and login using the `ssh_username` and `ssh_password` as configured in the variables block of `baseos.json` plan.

You can pause the build at a certain point by adding a breakpoint provisioner to the build plan. For example in order to inspect the baseos VM state after Docker has been installed, add the breakpoint provisioner after the shell provisioner running `install_docker.sh`:

```
{
  "type": "breakpoint",
  "only": ["baseos"]
}
```

## Publishing the image

The resulting `.qcow2` image can be uploaded to many common cloud providers to be used as a template for spinning up virtual machines.
This section describes some common cases.

### Upload to S3 bucket

Some cloud providers only support *pulling* the image, as opposed to "pushing" or uploading it directly.
This means that you will first need to make the image publicly accessible, for example by uploading it to an S3 bucket.

```bash
BUCKET_NAME=ck8s-base-os
VERSION=v0.0.5
CONFIG=s3cfg.ini
s3cmd --config ${CONFIG} put output-baseos/* s3://${BUCKET_NAME}/${VERSION}/
# Make publicly accessible
s3cmd --config ${CONFIG} setacl --acl-public --recursive s3://${BUCKET_NAME}/${VERSION}/
# Check public URL
s3cmd --config ${CONFIG} info s3://${BUCKET_NAME}/${VERSION}/baseos.qcow2
```

Using the public URL you can then import the image as a template for example on Exoscale.

### Upload to OpenStack

You can upload the image directly to OpenStack.

```bash
openstack image create --disk-format qcow2 --file output-baseos/baseos.qcow2 CK8S-BaseOS-${VERSION}
```
