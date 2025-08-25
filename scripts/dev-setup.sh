#!/bin/bash

# Development setup script for Konditorei Widget
# This script provides a clean, isolated development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Konditorei Widget - Development Environment Setup${NC}"
echo -e "${YELLOW}This will create a clean, isolated Docker environment${NC}"

# Function to show usage
show_usage() {
    echo -e "${GREEN}Usage: $0 [command]${NC}"
    echo ""
    echo "Commands:"
    echo "  start       - Start development environment"
    echo "  build       - Build production image"
    echo "  test        - Run tests in isolated environment"
    echo "  clean       - Clean up all containers and volumes"
    echo "  logs        - Show development logs"
    echo "  shell       - Open shell in development container"
    echo "  help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start     # Start development server"
    echo "  $0 build     # Build production image"
    echo "  $0 clean     # Clean up everything"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}Error: Docker is not running or not accessible${NC}"
        exit 1
    fi
}

# Function to start development environment
start_dev() {
    echo -e "${GREEN}Starting development environment...${NC}"
    check_docker
    
    # Clean up any existing containers
    docker-compose -f docker-compose.dev.yml down --remove-orphans 2>/dev/null || true
    
    # Start development environment using app Dockerfile
    docker-compose -f docker-compose.dev.yml up -d konditorei-frontend-dev konditorei-backend-dev
    
    echo -e "${GREEN}✅ Development environment started!${NC}"
    echo -e "${YELLOW}📱 Frontend: http://localhost:3000${NC}"
    echo -e "${YELLOW}🔧 Backend: http://localhost:8000${NC}"
    echo -e "${BLUE}📋 Use '$0 logs' to view logs${NC}"
    echo -e "${BLUE}🧹 Use '$0 clean' to clean up when done${NC}"
}

# Function to build production image
build_production() {
    echo -e "${GREEN}Building production image...${NC}"
    check_docker
    
    # Build production container using app Dockerfile
    docker-compose -f docker-compose.dev.yml --profile production up -d konditorei-frontend-prod
    
    echo -e "${GREEN}✅ Production build completed!${NC}"
    echo -e "${YELLOW}🌐 Production frontend: http://localhost:8080${NC}"
}

# Function to run tests
run_tests() {
    echo -e "${GREEN}Running tests in isolated environment...${NC}"
    check_docker
    
    # Create test container
    docker run --rm \
        -v "$(pwd)/frontend:/app" \
        -w /app \
        node:18-alpine \
        sh -c "
            npm install &&
            npm test -- --watchAll=false
        "
    
    echo -e "${GREEN}✅ Tests completed!${NC}"
}

# Function to show logs
show_logs() {
    echo -e "${GREEN}Showing development logs...${NC}"
    docker-compose -f docker-compose.dev.yml logs -f konditorei-frontend-dev
}

# Function to open shell in development container
open_shell() {
    echo -e "${GREEN}Opening shell in development container...${NC}"
    docker exec -it konditorei-frontend-dev sh
}

# Function to clean up everything
cleanup() {
    echo -e "${YELLOW}Cleaning up development environment...${NC}"
    check_docker
    
    # Stop and remove all containers
    docker-compose -f docker-compose.dev.yml down --remove-orphans --volumes
    
    # Run cleanup service
    docker-compose -f docker-compose.dev.yml --profile cleanup up cleanup
    
    # Remove any dangling images
    docker image prune -f
    
    echo -e "${GREEN}✅ Cleanup completed!${NC}"
    echo -e "${BLUE}All containers, volumes, and images have been removed.${NC}"
}

# Main script logic
case "${1:-help}" in
    "start")
        start_dev
        ;;
    "build")
        build_production
        ;;
    "test")
        run_tests
        ;;
    "logs")
        show_logs
        ;;
    "shell")
        open_shell
        ;;
    "clean"|"cleanup")
        cleanup
        ;;
    "help"|"--help"|"-h")
        show_usage
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_usage
        exit 1
        ;;
esac

