#!/bin/bash
set -e

ACCOUNT_ID="029799733507"
REGION="ap-south-1"
IMAGE=$(jq -r '.[0].imageUri' /opt/codedeploy-agent/deployment-root/*/*/deployment-archive/imagedefinitions.json)

echo "Pulling latest image: $IMAGE"
docker pull $IMAGE

echo "Stopping old container..."
docker stop myapp || true
docker rm myapp || true

echo "Starting new container..."
docker run -d --name myapp -p 3000:3000 $IMAGE

echo "Deployment completed."
