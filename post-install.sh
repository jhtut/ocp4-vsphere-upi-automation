#!/bin/bash

BUILD_LAB=gsslab

# Set the OCP version
if [ "$1" != "--silent" ]; then
    printf "Specify Build Name (gsslab, pek2lab, <custom> ): (Press ENTER for default: ${BUILD_LAB})\n"
    read -r BUILD_LAB_CHOICE
    if [ "${BUILD_LAB_CHOICE}" != "" ]; then
        BUILD_LAB=${BUILD_LAB_CHOICE}
    fi
fi
printf "* Cluster Name: ${BUILD_LAB}\n\n"

# Run Ansible post-install.yml playbook:
ansible-playbook -e "" -e @./vars/vars-${BUILD_LAB}.yml post-install.yml --vault-password-file=ocp4-vsphere-upi-automation-vault.yml --skip-tags=3,5,6,7,19,20
