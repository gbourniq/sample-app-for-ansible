#!/bin/bash

set -e  # exit with error status on first failure

# get and install dependencies
echo "Updating conda environment"
conda env update

# Activate env
echo "Activating conda environment"
source ${CONDA_BIN}/activate ${CONDA_ENVIRONMENT}