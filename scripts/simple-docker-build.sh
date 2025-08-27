#!/bin/bash

# Simple script to build Docker images for amd64 architecture
# Usage: ./simple-docker-build.sh <TAG>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <TAG>"
    echo "Example: $0 latest"
    echo "Example: $0 v1.0.0"
    exit 1
fi

TAG=$1
REGISTRY="docker4zerocool"

echo "Building Docker images for amd64 architecture..."
echo "Registry: $REGISTRY"
echo "Tag: $TAG"

# Set DOCKER_DEFAULT_PLATFORM to ensure amd64 builds
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Build frontend image
echo "Building frontend image..."
docker build --platform linux/amd64 \
  -t $REGISTRY/konditorei:$TAG \
  -t $REGISTRY/konditorei:latest \
  ./frontend

# Build backend image
echo "Building backend image..."
docker build --platform linux/amd64 \
  -t $REGISTRY/konditorei-backend:$TAG \
  -t $REGISTRY/konditorei-backend:latest \
  ./backend

# Push images
echo "Pushing frontend image..."
docker push $REGISTRY/konditorei:$TAG
docker push $REGISTRY/konditorei:latest

echo "Pushing backend image..."
docker push $REGISTRY/konditorei-backend:$TAG
docker push $REGISTRY/konditorei-backend:latest

echo "Images built and pushed successfully!"
echo "Frontend: $REGISTRY/konditorei:$TAG"
echo "Backend: $REGISTRY/konditorei-backend:$TAG"
