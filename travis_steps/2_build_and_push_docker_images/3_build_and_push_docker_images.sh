#!/bin/bash

set -xe #  exit as soon as any command returns a nonzero status

# Activate conda env - need to install conda on travis instance
# source "${CONDA_BIN}/..${conda_prefix}/etc/profile.d/conda.sh"; conda activate devops-test

# Remove all running containers, and run docker system prune"
make ansible-instance-cleanup

# Running ansible playbook for build deployment: 
# > build images, test containers and push images to registry
make ansible-deploy-build
	
