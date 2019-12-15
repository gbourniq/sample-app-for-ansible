#!/usr/bin/env bash

set -e  # exit with error status on first failure

image_to_scan=${DOCKER_REGISTRY}/${ORG_NAME}/${REPO_NAME_BASE}_app:latest

echo "Adding docker registry"

docker-compose exec -T engine-api anchore-cli registry del ${DOCKER_REGISTRY}
docker-compose exec -T engine-api anchore-cli registry add ${DOCKER_REGISTRY} ${DOCKER_USER} ${dockerPassword}

echo "Adding image"
docker-compose exec -T engine-api anchore-cli image add ${image_to_scan}

echo "Scanning image..."
docker-compose exec -T engine-api anchore-cli image wait ${image_to_scan}

echo "Check for vulnerabilities"
docker-compose exec -T engine-api anchore-cli image vuln ${image_to_scan} all

echo "Evaluate the image against policies to check for security compliance"
docker-compose exec -T engine-api anchore-cli evaluate check ${image_to_scan} --detail

docker-compose down
