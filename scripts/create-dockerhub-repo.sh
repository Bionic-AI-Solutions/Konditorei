#!/bin/bash

# Script to create Docker Hub repository
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐳 Docker Hub Repository Creation${NC}"
echo -e "${YELLOW}This script will help you create the Docker Hub repository${NC}"

# Function to check if Docker Hub credentials are available
check_credentials() {
    if [ -z "$DOCKERHUB_USER" ] || [ -z "$DOCKERHUB_TOKEN" ]; then
        echo -e "${RED}Error: DOCKERHUB_USER and DOCKERHUB_TOKEN environment variables are required${NC}"
        echo -e "${YELLOW}Please set them first:${NC}"
        echo -e "export DOCKERHUB_USER=your_username"
        echo -e "export DOCKERHUB_TOKEN=your_token"
        exit 1
    fi
}

# Function to create repository via API
create_repository() {
    echo -e "${GREEN}Creating Docker Hub repository...${NC}"
    
    # Create the repository using Docker Hub API
    response=$(curl -s -X POST \
        -H "Content-Type: application/json" \
        -H "Authorization: JWT $(curl -s -X POST \
            -H "Content-Type: application/json" \
            -d "{\"username\":\"$DOCKERHUB_USER\",\"password\":\"$DOCKERHUB_TOKEN\"}" \
            https://hub.docker.com/v2/users/login/ | jq -r '.token')" \
        -d '{
            "name": "konditorei",
            "description": "AI-powered landing page for Konditorei Cafe",
            "is_private": false,
            "full_description": "A React-based web application that hosts the ElevenLabs Convai widget, designed for deployment on Kubernetes clusters through ArgoCD."
        }' \
        https://hub.docker.com/v2/repositories/bionicaisolutions/)
    
    if echo "$response" | grep -q "already exists"; then
        echo -e "${YELLOW}Repository already exists!${NC}"
        return 0
    elif echo "$response" | grep -q "name"; then
        echo -e "${GREEN}✅ Repository created successfully!${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to create repository${NC}"
        echo -e "${YELLOW}Response: $response${NC}"
        return 1
    fi
}

# Function to show manual instructions
show_manual_instructions() {
    echo -e "${BLUE}📋 Manual Creation Instructions:${NC}"
    echo -e "${YELLOW}If the automated creation fails, please create the repository manually:${NC}"
    echo ""
    echo -e "1. Go to https://hub.docker.com"
    echo -e "2. Click 'Create Repository'"
    echo -e "3. Repository Details:"
    echo -e "   - Name: konditorei"
    echo -e "   - Namespace: bionicaisolutions"
    echo -e "   - Visibility: Public"
    echo -e "   - Description: AI-powered landing page for Konditorei Cafe"
    echo -e "4. Click 'Create'"
    echo ""
    echo -e "${GREEN}Once created, the CI/CD pipeline will be able to push images!${NC}"
}

# Main execution
main() {
    check_credentials
    
    echo -e "${GREEN}Using Docker Hub user: $DOCKERHUB_USER${NC}"
    
    # Try to create repository
    if create_repository; then
        echo -e "${GREEN}🎉 Repository setup complete!${NC}"
        echo -e "${YELLOW}The CI/CD pipeline should now be able to push images.${NC}"
    else
        echo -e "${RED}❌ Automated creation failed${NC}"
        show_manual_instructions
    fi
}

# Run main function
main
