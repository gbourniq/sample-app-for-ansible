#!/bin/bash

VAULT="github-deployment/roles/setup/vars/ansible-vault-pw"
INVENTORY_FILE="inventory.yml"
PLAYBOOK="site.yml"

ansible-playbook -i $INVENTORY_FILE --vault-id $VAULT $PLAYBOOK