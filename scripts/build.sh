#!/bin/bash

# Build script for Konditorei Widget
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building Konditorei Widget Docker Image...${NC}"

# Set variables
IMAGE_NAME="konditorei-frontend"
TAG=${1:-latest}
REGISTRY=${2:-""}

# Build the Docker image
echo -e "${YELLOW}Building frontend image...${NC}"
docker build -t ${IMAGE_NAME}:${TAG} ./frontend

# Tag for registry if provided
if [ ! -z "$REGISTRY" ]; then
    echo -e "${YELLOW}Tagging for registry: ${REGISTRY}${NC}"
    docker tag ${IMAGE_NAME}:${TAG} ${REGISTRY}/${IMAGE_NAME}:${TAG}
fi

echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${YELLOW}Image: ${IMAGE_NAME}:${TAG}${NC}"
if [ ! -z "$REGISTRY" ]; then
    echo -e "${YELLOW}Registry Image: ${REGISTRY}/${IMAGE_NAME}:${TAG}${NC}"
fi

