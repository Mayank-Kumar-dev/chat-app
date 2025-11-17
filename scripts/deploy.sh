#!/bin/bash
set -e

echo "Finding imagedefinitions.json..."
JSON_PATH=$(find /opt/codedeploy-agent/deployment-root/ -name imagedefinitions.json -print -quit)

echo "Using JSON at: $JSON_PATH"

IMAGE=$(jq -r '.[0].imageUri' "$JSON_PATH")

echo "Pulling latest image: $IMAGE"
docker pull $IMAGE

echo "Stopping old container..."
docker stop myapp || true
docker rm myapp || true

echo "Starting new container..."
docker run -d --name myapp -p 3000:3000 $IMAGE

echo "Deployment completed."
