#!/bin/bash

# Script to update Kubernetes manifests with correct image tags
# Usage: ./update-image-tags.sh <DOCKER_REGISTRY> <TAG>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <DOCKER_REGISTRY> <TAG>"
    echo "Example: $0 bionicaisolutions latest"
    exit 1
fi

DOCKER_REGISTRY=$1
TAG=${2:-latest}

echo "Updating Kubernetes manifests with images from $DOCKER_REGISTRY:$TAG..."

# Update frontend deployment
echo "Updating frontend deployment..."
sed -i.bak "s|image:.*konditorei.*|image: $DOCKER_REGISTRY/konditorei:$TAG|g" k8s/deployment.yaml

# Update backend deployment
echo "Updating backend deployment..."
sed -i.bak "s|image:.*konditorei-backend.*|image: $DOCKER_REGISTRY/konditorei-backend:$TAG|g" k8s/backend-deployment.yaml

echo "Kubernetes manifests updated successfully!"
echo "Frontend image: $DOCKER_REGISTRY/konditorei:$TAG"
echo "Backend image: $DOCKER_REGISTRY/konditorei-backend:$TAG"

# Clean up backup files
rm -f k8s/*.bak

echo "Backup files cleaned up."
