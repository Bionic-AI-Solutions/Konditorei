#!/bin/bash

# Isolated build script for Konditorei Widget
# This script builds everything in a clean Docker environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔨 Konditorei Widget - Isolated Build${NC}"
echo -e "${YELLOW}Building in clean Docker environment...${NC}"

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}Error: Docker is not running or not accessible${NC}"
        exit 1
    fi
}

# Function to build frontend
build_frontend() {
    echo -e "${GREEN}Building frontend...${NC}"
    
    # Create a temporary build container
    docker run --rm \
        -v "$(pwd)/frontend:/app" \
        -w /app \
        node:18-alpine \
        sh -c "
            npm install &&
            npm run build
        "
    
    echo -e "${GREEN}✅ Frontend build completed!${NC}"
}

# Function to build Docker images
build_images() {
    echo -e "${GREEN}Building Docker images...${NC}"
    
    # Build frontend image
    docker build -t konditorei-frontend:latest ./frontend
    
    # Build backend image
    docker build -t konditorei-backend:latest ./backend
    
    echo -e "${GREEN}✅ Docker images built successfully!${NC}"
}

# Function to test the build
test_build() {
    echo -e "${GREEN}Testing the build...${NC}"
    
    # Start containers for testing
    docker-compose -f docker-compose.prod.yml up -d
    
    # Wait for services to be ready
    echo -e "${YELLOW}Waiting for services to be ready...${NC}"
    sleep 30
    
    # Test frontend
    if curl -f http://localhost/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Frontend health check passed${NC}"
    else
        echo -e "${RED}❌ Frontend health check failed${NC}"
        return 1
    fi
    
    # Test backend
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Backend health check passed${NC}"
    else
        echo -e "${RED}❌ Backend health check failed${NC}"
        return 1
    fi
    
    # Stop test containers
    docker-compose -f docker-compose.prod.yml down
    
    echo -e "${GREEN}✅ Build test completed successfully!${NC}"
}

# Function to clean up build artifacts
cleanup_build() {
    echo -e "${YELLOW}Cleaning up build artifacts...${NC}"
    
    # Remove build containers and images
    docker system prune -f
    
    echo -e "${GREEN}✅ Build cleanup completed!${NC}"
}

# Main build process
main() {
    check_docker
    
    # Clean up any existing containers
    docker-compose -f docker-compose.prod.yml down --remove-orphans 2>/dev/null || true
    
    # Build frontend
    build_frontend
    
    # Build Docker images
    build_images
    
    # Test the build
    test_build
    
    # Clean up
    cleanup_build
    
    echo -e "${GREEN}🎉 Build completed successfully!${NC}"
    echo -e "${BLUE}Images created:${NC}"
    echo -e "${YELLOW}  - konditorei-frontend:latest${NC}"
    echo -e "${YELLOW}  - konditorei-backend:latest${NC}"
}

# Run main function
main

