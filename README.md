# DEPRECATED

NOTE: This repository is no longer maintained since Compliant Kubernetes has moved on to use Kubespray, which makes the Base VM template obsolete.

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

* Packer 1.6+ (https://www.packer.io/downloads.html)
* KVM (https://help.ubuntu.com/community/KVM/Installation)
* Ansible (https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (tested with 2.9.7)

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

## Non-image environments

In environments where images are not an option, e.g. bare-metal that are not provisioned using machine images, the Ansible playbooks can be run manually.

```
ansible-playbook -i [inventory] -e @variables.json ansible/provision.yaml
```

To undo the provisioning run:

```
ansible-playbook -i [inventory] ansible/reset.yaml
```

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

### Create an AMI
Creating an AMI from the qcow2 image requires multiple steps, one of which is to convert it to a 20 GB .raw file and upload it to an S3 bucket. It is therefor recommended to do this on a good connection.

This section is based on a [post](https://www.wavether.com/2016/11/import-qcow2-images-into-aws), with some changes and additions.

#### Pre-requisites
- AWS CLI
- qemu-utils:
  ```
  $ sudo apt-get install qemu-utils
  ```
- An S3 bucket to store the intermediate raw image file, with public access unblocked

#### Steps

1. Build and test the baseos image as usual.

2. Convert the image to raw format:
   ```
   $ qemu-img convert baseos.qcow baseos-my-version.raw
   ```

3. Upload the .raw image:

   ```
   $ aws s3 cp baseos-my-version.raw s3://my-s3-bucket
   ```

   This should take about 30 minutes on a 100 Mbit connection.

4. Create an IAM role `vmimport` with [trust and role policies](https://docs.aws.amazon.com/vm-import/latest/userguide/vmie_prereqs.html#vmimport-role). This only needs to be done once, if multiple AMIs are to be created.

    4.1. Create `trust-policy.json`:
    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": { "Service": "vmie.amazonaws.com" },
                "Action": "sts:AssumeRole",
                "Condition": {
                    "StringEquals":{
                    "sts:Externalid": "vmimport"
                    }
                }
            }
        ]
    }
    ```

    4.2. Create `vmimport` role with the trust policy:

        $ aws iam create-role --role-name vmimport --assume-role-policy-document "file://$(pwd)/trust-policy.json"


    4.3. Create `role-policy.json`, filling in the name of the S3 bucket:
    ```json
    {
        "Version":"2012-10-17",
        "Statement":[
            {
                "Effect":"Allow",
                "Action":[
                    "s3:GetBucketLocation",
                    "s3:GetObject",
                    "s3:ListBucket"
                ],
                "Resource":[
                    "arn:aws:s3:::my-s3-bucket",
                    "arn:aws:s3:::my-s3-bucket/*"
                ]
            },
            {
                "Effect":"Allow",
                "Action":[
                    "s3:GetBucketLocation",
                    "s3:GetObject",
                    "s3:ListBucket",
                    "s3:PutObject",
                    "s3:GetBucketAcl"
                ],
                "Resource":[
                    "arn:aws:s3:::my-s3-bucket",
                    "arn:aws:s3:::my-s3-bucket/*"
                ]
            },
            {
                "Effect":"Allow",
                "Action":[
                    "ec2:ModifySnapshotAttribute",
                    "ec2:CopySnapshot",
                    "ec2:RegisterImage",
                    "ec2:Describe*"
                ],
                "Resource":"*"
            }
        ]
    }
    ```
    4.4. Use the role policy:


        $ aws iam put-role-policy --role-name vmimport --policy-name vmimport --policy-document "file://$(pwd)/role-policy.json"


5. Generate a pre-signed url for bucket access:
   ```
   $ aws s3 presign s3://my-s3-bucket/baseos-my-version.raw
   ```

6. Create `container.json` with the pre-signed url:
   ```json
   {
       "Description": "BaseOS my-version raw image",
       "Format": "raw",
       "Url": "<pre-signed url>"
   }
   ```

7. Use the import-snapshot tool with `container.json`:
   ```
   $ aws ec2 import-snapshot --description "baseos my-version" --disk-container file://$(pwd)/container.json
   ```
   and wait until the snapshot appears in the AWS console under EC2->Elastic Block Storage->Snapshots.

8. Select the newly created snapshot. Add a tag with version information, such as "baseos k8s version" : "1.17.05", to make it easier to identify. Then choose Actions->Create image, fill in the name, and click Create to finish AMI creation.

**Note**: To be able to use the image from another AWS account, add that
account number under Actions->Modify Image Permissions.
