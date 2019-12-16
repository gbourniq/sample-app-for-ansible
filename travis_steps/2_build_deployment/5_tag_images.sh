#!/bin/bash

set -xe #  exit as soon as any command returns a nonzero status

# Activate conda env - need to install conda on travis instance
# source "${CONDA_BIN}/..${conda_prefix}/etc/profile.d/conda.sh"; conda activate devops-test

# Running ansible playbook to tag images:
make ansible-tag-images