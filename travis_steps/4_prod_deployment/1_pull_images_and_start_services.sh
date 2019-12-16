#!/usr/bin/env bash

set -e  # exit with error status on first failure

# Remove all running containers, and run docker system prune"
make ansible-instance-cleanup

# Running ansible playbook for build deployment
make ansible-deploy-prod