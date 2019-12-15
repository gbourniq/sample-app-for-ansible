#!/usr/bin/env bash

set -e  # exit with error status on first failure

make docker-login

echo "Install Anchore for security scans..."
docker pull docker.io/anchore/anchore-engine:latest
docker create --name ae docker.io/anchore/anchore-engine:latest
docker cp ae:/docker-compose.yaml docker-compose.yaml
docker rm ae

echo "Run Anchore server..."
docker-compose up -d

CONTAINERS=$(docker-compose ps -q)
for container in $CONTAINERS
do
  container_state=$(docker inspect -f {{.State.Running}} "${container}")
  echo $container
  echo $container_state
  until [ "${container_state}" = "true" ]
  do
    echo "Not ready yet..."
    sleep 1;
  done;
done;
