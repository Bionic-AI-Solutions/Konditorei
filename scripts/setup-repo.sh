#!/bin/bash

# Setup script for Konditorei repository
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Konditorei Repository Setup${NC}"
echo -e "${YELLOW}This script will help you set up the repository for GitHub and Docker Hub integration${NC}"

# Function to check if git is available
check_git() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: git is not installed or not in PATH${NC}"
        exit 1
    fi
}

# Function to initialize git repository
init_git() {
    echo -e "${GREEN}Initializing git repository...${NC}"
    
    if [ ! -d ".git" ]; then
        git init
        echo -e "${GREEN}✅ Git repository initialized${NC}"
    else
        echo -e "${YELLOW}Git repository already exists${NC}"
    fi
}

# Function to add all files
add_files() {
    echo -e "${GREEN}Adding files to git...${NC}"
    git add .
    echo -e "${GREEN}✅ Files added to git${NC}"
}

# Function to create initial commit
create_commit() {
    echo -e "${GREEN}Creating initial commit...${NC}"
    git commit -m "Initial commit: Konditorei Cafe AI-powered landing page

- React application with ElevenLabs Convai widget integration
- Docker containerization for frontend and backend
- Kubernetes manifests for deployment
- ArgoCD application configuration
- GitHub Actions CI/CD pipeline
- Complete replica of Konditorei Cafe website"
    echo -e "${GREEN}✅ Initial commit created${NC}"
}

# Function to show next steps
show_next_steps() {
    echo -e "${BLUE}📋 Next Steps:${NC}"
    echo -e "${YELLOW}1. Create repository on GitHub:${NC}"
    echo -e "   - Go to https://github.com/Bionic-AI-Solutions"
    echo -e "   - Click 'New repository'"
    echo -e "   - Name: Konditorei"
    echo -e "   - Description: AI-powered landing page for Konditorei Cafe"
    echo -e "   - Make it Public"
    echo -e "   - Don't initialize with README (we already have one)"
    echo ""
    echo -e "${YELLOW}2. Add remote and push:${NC}"
    echo -e "   git remote add origin https://github.com/Bionic-AI-Solutions/Konditorei.git"
    echo -e "   git branch -M main"
    echo -e "   git push -u origin main"
    echo ""
    echo -e "${YELLOW}3. Set up GitHub Secrets:${NC}"
    echo -e "   - DOCKERHUB_USER: Your Docker Hub username"
    echo -e "   - DOCKERHUB_TOKEN: Your Docker Hub access token"
    echo -e "   - KUBE_CONFIG: Base64 encoded kubeconfig for your cluster"
    echo ""
    echo -e "${YELLOW}4. Deploy to Kubernetes:${NC}"
    echo -e "   kubectl apply -f k8s/"
    echo -e "   kubectl apply -f argocd/konditorei-app.yaml"
    echo ""
    echo -e "${GREEN}🎉 Repository setup complete!${NC}"
}

# Main execution
main() {
    check_git
    init_git
    add_files
    create_commit
    show_next_steps
}

# Run main function
main
