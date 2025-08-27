#!/bin/bash

# Script to build and push Docker images for Konditorei
# Usage: ./build-and-push-images.sh <DOCKER_REGISTRY> <TAG>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <DOCKER_REGISTRY> <TAG>"
    echo "Example: $0 bionicaisolutions latest"
    echo "Example: $0 docker.io/yourusername v1.0.0"
    exit 1
fi

DOCKER_REGISTRY=$1
TAG=${2:-latest}

echo "Building and pushing Docker images to $DOCKER_REGISTRY with tag $TAG..."

# Build frontend image
echo "Building frontend image..."
docker build -t $DOCKER_REGISTRY/konditorei:$TAG ./frontend

# Build backend image
echo "Building backend image..."
docker build -t $DOCKER_REGISTRY/konditorei-backend:$TAG ./backend

# Push images
echo "Pushing frontend image..."
docker push $DOCKER_REGISTRY/konditorei:$TAG

echo "Pushing backend image..."
docker push $DOCKER_REGISTRY/konditorei-backend:$TAG

echo "Images built and pushed successfully!"
echo "Frontend: $DOCKER_REGISTRY/konditorei:$TAG"
echo "Backend: $DOCKER_REGISTRY/konditorei-backend:$TAG"
