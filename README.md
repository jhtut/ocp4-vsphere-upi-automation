# OCP4 on VMware vSphere UPI Automation

The goal of this repo is to make deploying and redeploying a new Openshift v4 cluster fully automated. This has been created to avoid any manual operation for a VMware OpenShift User Provisioned Infrastructure (UPI) implementation.

## Prerequisites

With all the details in hand from the prerequisites, populate the **vars/vars-${BUILD_LAB}.yml** in the root folder of this repo and trigger the installation seen in the example runs. 

## Requirements

* Ansible `2.X`
* Python module `openshift-0.10.3` or higher (you might have to do `alternatives --install /usr/bin/python python /usr/bin/python3 1 ; pip3 install openshift --user`)

## Examples Runs

### Automated Build with Prompted options with Vault Encrypted Vars and Version Status Checking

```bash
./cluster-build.sh
Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)
pek2lab
* Cluster Name: pek2lab

Enter OpenShift Version: (Press ENTER for default: 4.3.8)
4.3.9
* Using: 4.3.9

Enter OpenShift Cluster Size (small [8gb,2vcpu],medium [32gb,4vcpu],large [64gb,8vcpu]): (Press ENTER for default: small )
medium
* Using: medium Cluster Settings Memory 32768 CPU 4

Enter OpenShift Disconnected setting true/false: (Press ENTER for default: false)
false
* Disconnected Setting: false

Enable OpenShift Container Storage (OCS) true/false: (Press ENTER for default: false)
true
* OpenShift Container Storage (OCS) Setting: true
```
### Automated Build with Prompted options No Vault Encrypted Vars and Version Status Checking

```bash
./cluster-build-novault.sh
```

## Helper Node Build

```bash
./helpernode-build.sh
Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab
```

## Manual install

### Prepare OCP OVA, Ignition and install configuration

```bash
ansible-playbook -e "ocp_version=${DEFAULT_OCPVERSION} disconnected_setting=${DISCONNECTED}" -e @./vars/vars-${BUILD_LAB}.yml setup-ocp-vsphere.yml --ask-vault-pass
```
### Transfer Ignition files

```bash
cp install-dir/bootstrap.ign /var/www/html/ignition
```

### Change file permissions

```bash
chmod 644 /var/www/html/ignition/bootstrap.ign
```

### Configure the vSphere cluster with the OpenShift instances

```bash
ansible-playbook -e "ocp_version=${DEFAULT_OCPVERSION} worker_memory=${WORKER_MEMORY} worker_cpu=${WORKER_CPU} disconnected_setting=${DISCONNECTED}" -e @./vars/vars-${BUILD_LAB}.yml setup-vcenter-vms.yml --ask-vault-pass
```

### Export the Kubernetes Authentication variable

```bash
export KUBECONFIG=/root/ocp4-vsphere-upi-automation/install-dir/auth/kubeconfig
```

### Review the installation progress

```bash
bin/openshift-install wait-for install-complete --dir=/root/ocp4-vsphere-upi-automation/install-dir
```

### SSH to the Bootstrap node

```bash
ssh core@192.168.0.xxx
```
### Review the Boostrap service

```bash
journalctl -b -f -u bootkube.service
```

## Post Deployment Tasks

```bash
ansible-playbook -e @./vars/vars-{CUSTOMER}.yml post-install.yml --ask-vault-pass
```

## Cluster Node Scaling

## Scale Up Worker Nodes (Default 3 nodes)

```bash
./scale-up-nodes.sh
Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab

Enter OpenShift Worker Node Size (small [8gb,2vcpu],medium [32gb,4vcpu],large [64gb,8vcpu]): (Press ENTER for default: small )

* Using:  Cluster Settings Memory 8192 CPU 2
```

## Scale Down Worker Nodes (Default 3 nodes)

```bash
./scale-down-nodes.sh
Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab
```

## Disconnected Setup

### Repo Sync with versioning

```bash
./disconnected-sync.sh
Enter OpenShift Version: (Press ENTER for default: 4.3.8)
4.3.8
* Using: 4.3.8
info: Mirroring 103 images to registry.ocp4.gsslab.brq.redhat.com:443/openshift/ocp4.3.8-x86_64 ...
```
### OLM Sync

```bash
./disconnected-operators.sh
```
## Destroy Cluster

### Cluster Destroy Vault

```bash
./cluster-destroy.sh
Specify Cluster Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab
```

### Cluster Destroy No Vault

```bash
./cluster-destroy-novault.sh
Specify Cluster Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: gsslab)

* Cluster Name: gsslab
```
