#!/bin/bash
set -e

IMAGE="thiexco/flask-demo"
TAG="${1:-latest}"

echo "Building ${IMAGE}:${TAG}..."
docker build -t "${IMAGE}:${TAG}" .

echo "Pushing ${IMAGE}:${TAG}..."
docker push "${IMAGE}:${TAG}"

if [ "${TAG}" != "latest" ]; then
  docker tag "${IMAGE}:${TAG}" "${IMAGE}:latest"
  docker push "${IMAGE}:latest"
  echo "Also pushed ${IMAGE}:latest"
fi

echo "Done: ${IMAGE}:${TAG}"
