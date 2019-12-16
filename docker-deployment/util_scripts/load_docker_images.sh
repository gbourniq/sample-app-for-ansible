#!/bin/bash
set -e  # exit with error status on first failure

SCRIPT_PATH="`dirname \"$0\"`"
for filename in $SCRIPT_PATH/../docker_images/*.tar.gz; do
    docker load -i "$filename"
done
