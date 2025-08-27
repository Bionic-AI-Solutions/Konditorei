#!/bin/bash

# Script to build Docker images in a containerized environment for amd64 architecture
# Usage: ./docker-build.sh <TAG>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <TAG>"
    echo "Example: $0 latest"
    echo "Example: $0 v1.0.0"
    exit 1
fi

TAG=$1
REGISTRY="docker4zerocool"

echo "Building Docker images for amd64 architecture in containerized environment..."
echo "Registry: $REGISTRY"
echo "Tag: $TAG"

# Create a temporary Dockerfile for building
cat > Dockerfile.build << 'EOF'
FROM --platform=linux/amd64 ubuntu:22.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz | tar -xzC /usr/local/bin --strip=1 docker/docker

# Install Docker Buildx
RUN curl -L https://github.com/docker/buildx/releases/download/v0.12.1/buildx-v0.12.1.linux-amd64 -o /usr/local/bin/docker-buildx && \
    chmod +x /usr/local/bin/docker-buildx

# Set up buildx
RUN docker buildx create --name multiarch-builder && \
    docker buildx use multiarch-builder

WORKDIR /workspace

# Copy the build script
COPY build-images.sh /workspace/
RUN chmod +x /workspace/build-images.sh

ENTRYPOINT ["/workspace/build-images.sh"]
EOF

# Create the build script that will run inside the container
cat > build-images.sh << EOF
#!/bin/bash
set -e

echo "Starting build process for amd64 architecture..."

# Build frontend image for amd64
echo "Building frontend image..."
docker buildx build --platform linux/amd64 \
  -t $REGISTRY/konditorei:$TAG \
  -t $REGISTRY/konditorei:latest \
  --push \
  ./frontend

# Build backend image for amd64
echo "Building backend image..."
docker buildx build --platform linux/amd64 \
  -t $REGISTRY/konditorei-backend:$TAG \
  -t $REGISTRY/konditorei-backend:latest \
  --push \
  ./backend

echo "Images built and pushed successfully!"
echo "Frontend: $REGISTRY/konditorei:$TAG"
echo "Backend: $REGISTRY/konditorei-backend:$TAG"
EOF

# Build the builder image
echo "Building the builder container..."
docker build -f Dockerfile.build -t konditorei-builder .

# Run the builder container with Docker socket mounted
echo "Running build process..."
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd):/workspace \
  -w /workspace \
  konditorei-builder

# Clean up
echo "Cleaning up build files..."
rm -f Dockerfile.build build-images.sh

echo "Build process completed!"
