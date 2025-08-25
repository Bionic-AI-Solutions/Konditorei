#!/bin/bash

# Test script for Konditorei Widget
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Testing Konditorei Widget...${NC}"

# Function to test local development
test_local() {
    echo -e "${YELLOW}Testing local development environment...${NC}"
    
    # Start local development
    docker-compose up -d
    
    # Wait for service to be ready
    echo -e "${YELLOW}Waiting for service to be ready...${NC}"
    sleep 30
    
    # Test health endpoint
    if curl -f http://localhost:3000/health; then
        echo -e "${GREEN}✓ Health check passed${NC}"
    else
        echo -e "${RED}✗ Health check failed${NC}"
        return 1
    fi
    
    # Test main page
    if curl -f http://localhost:3000/ | grep -q "Konditorei"; then
        echo -e "${GREEN}✓ Main page loaded successfully${NC}"
    else
        echo -e "${RED}✗ Main page failed to load${NC}"
        return 1
    fi
    
    # Stop local development
    docker-compose down
}

# Function to test production build
test_production() {
    echo -e "${YELLOW}Testing production build...${NC}"
    
    # Build production image
    ./scripts/build.sh
    
    # Start production environment
    docker-compose -f docker-compose.prod.yml up -d
    
    # Wait for service to be ready
    echo -e "${YELLOW}Waiting for service to be ready...${NC}"
    sleep 30
    
    # Test health endpoint
    if curl -f http://localhost/health; then
        echo -e "${GREEN}✓ Production health check passed${NC}"
    else
        echo -e "${RED}✗ Production health check failed${NC}"
        return 1
    fi
    
    # Test main page
    if curl -f http://localhost/ | grep -q "Konditorei"; then
        echo -e "${GREEN}✓ Production main page loaded successfully${NC}"
    else
        echo -e "${RED}✗ Production main page failed to load${NC}"
        return 1
    fi
    
    # Stop production environment
    docker-compose -f docker-compose.prod.yml down
}

# Function to test Kubernetes deployment
test_kubernetes() {
    echo -e "${YELLOW}Testing Kubernetes deployment...${NC}"
    
    # Check if kubectl is available
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}Error: kubectl is not installed or not in PATH${NC}"
        return 1
    fi
    
    # Check namespace
    if kubectl get namespace konditorei &> /dev/null; then
        echo -e "${GREEN}✓ Namespace exists${NC}"
    else
        echo -e "${RED}✗ Namespace does not exist${NC}"
        return 1
    fi
    
    # Check pods
    if kubectl get pods -n konditorei | grep -q "Running"; then
        echo -e "${GREEN}✓ Pods are running${NC}"
    else
        echo -e "${RED}✗ Pods are not running${NC}"
        return 1
    fi
    
    # Check services
    if kubectl get services -n konditorei | grep -q "konditorei-frontend-service"; then
        echo -e "${GREEN}✓ Service exists${NC}"
    else
        echo -e "${RED}✗ Service does not exist${NC}"
        return 1
    fi
    
    # Check ingress
    if kubectl get ingress -n konditorei | grep -q "konditorei-ingress"; then
        echo -e "${GREEN}✓ Ingress exists${NC}"
    else
        echo -e "${RED}✗ Ingress does not exist${NC}"
        return 1
    fi
}

# Main test execution
case "${1:-all}" in
    "local")
        test_local
        ;;
    "production")
        test_production
        ;;
    "kubernetes")
        test_kubernetes
        ;;
    "all")
        test_local
        test_production
        test_kubernetes
        ;;
    *)
        echo -e "${RED}Usage: $0 [local|production|kubernetes|all]${NC}"
        exit 1
        ;;
esac

echo -e "${GREEN}All tests completed successfully!${NC}"

