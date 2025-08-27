#!/bin/bash

# Fully containerized build script that doesn't pollute local environment
# Usage: ./containerized-build.sh <TAG>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <TAG>"
    echo "Example: $0 latest"
    echo "Example: $0 v1.0.0"
    exit 1
fi

TAG=$1
REGISTRY="docker4zerocool"

echo "Building Docker images in fully containerized environment..."
echo "Registry: $REGISTRY"
echo "Tag: $TAG"

# Create a Dockerfile for the build environment
cat > Dockerfile.build-env << 'EOF'
FROM --platform=linux/amd64 ubuntu:22.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    build-essential \
    nodejs \
    npm \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz | tar -xzC /usr/local/bin --strip=1 docker/docker

WORKDIR /workspace

# Copy the build script
COPY build-in-container.sh /workspace/
RUN chmod +x /workspace/build-in-container.sh

CMD ["/workspace/build-in-container.sh"]
EOF

# Create the build script that runs inside the container
cat > build-in-container.sh << 'EOF'
#!/bin/bash
set -e

echo "Starting containerized build process..."

# Update npm packages in frontend (inside container)
echo "Updating frontend dependencies..."
cd /workspace/frontend
npm install

# Build frontend image
echo "Building frontend image..."
cd /workspace
docker build --platform linux/amd64 \
  -t docker4zerocool/konditorei:latest \
  -t docker4zerocool/konditorei:latest \
  ./frontend

# Build backend image
echo "Building backend image..."
docker build --platform linux/amd64 \
  -t docker4zerocool/konditorei-backend:latest \
  -t docker4zerocool/konditorei-backend:latest \
  ./backend

# Push images
echo "Pushing frontend image..."
docker push docker4zerocool/konditorei:latest
docker push docker4zerocool/konditorei:latest

echo "Pushing backend image..."
docker push docker4zerocool/konditorei-backend:latest
docker push docker4zerocool/konditorei-backend:latest

echo "Images built and pushed successfully!"
echo "Frontend: docker4zerocool/konditorei:latest"
echo "Backend: docker4zerocool/konditorei-backend:latest"
EOF

# Build the build environment container
echo "Building the build environment container..."
docker build -f Dockerfile.build-env -t konditorei-build-env .

# Run the build process in the container
echo "Running build process in container..."
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd):/workspace \
  -w /workspace \
  konditorei-build-env

# Clean up build files
echo "Cleaning up build files..."
rm -f Dockerfile.build-env build-in-container.sh

echo "Containerized build process completed!"
