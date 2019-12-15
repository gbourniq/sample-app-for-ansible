#!/bin/bash

set -xe #  exit as soon as any command returns a nonzero status

# Populate ansible vault passphrase
touch ec2-deployment/roles/setup/vars/ansible-vault-pw
echo ${ANSIBLE_VAULT_PASSPHRASE} > ec2-deployment/roles/setup/vars/ansible-vault-pw

# Checking ansible command syntax...
make ansible-checksyntax

# Populate inventory file with ec2 public IP address
make ansible-define-host

# Running ansible playbook for machine setup
make ansible-instance-setup