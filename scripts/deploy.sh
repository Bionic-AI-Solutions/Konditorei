#!/bin/bash

# Deployment script for Konditorei Widget
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Deploying Konditorei Widget to Kubernetes...${NC}"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl is not installed or not in PATH${NC}"
    exit 1
fi

# Check if ArgoCD CLI is available
if ! command -v argocd &> /dev/null; then
    echo -e "${YELLOW}Warning: ArgoCD CLI not found. Please install it for better deployment management.${NC}"
fi

# Set variables
NAMESPACE="konditorei"
APP_NAME="konditorei-widget"

# Create namespace if it doesn't exist
echo -e "${YELLOW}Creating namespace if it doesn't exist...${NC}"
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# Apply Kubernetes manifests
echo -e "${YELLOW}Applying Kubernetes manifests...${NC}"
kubectl apply -f k8s/ -n ${NAMESPACE}

# Apply ArgoCD application if ArgoCD CLI is available
if command -v argocd &> /dev/null; then
    echo -e "${YELLOW}Applying ArgoCD application...${NC}"
    kubectl apply -f argocd/konditorei-app.yaml
    
    echo -e "${YELLOW}Syncing ArgoCD application...${NC}"
    argocd app sync ${APP_NAME}
    
    echo -e "${YELLOW}Waiting for ArgoCD application to be healthy...${NC}"
    argocd app wait ${APP_NAME} --health --timeout 300
else
    echo -e "${YELLOW}ArgoCD CLI not available. Manifests applied directly to Kubernetes.${NC}"
fi

# Check deployment status
echo -e "${YELLOW}Checking deployment status...${NC}"
kubectl get pods -n ${NAMESPACE}
kubectl get services -n ${NAMESPACE}
kubectl get ingress -n ${NAMESPACE}

echo -e "${GREEN}Deployment completed!${NC}"
echo -e "${YELLOW}Application will be available at: https://konditorei.bionicaisolutions.com${NC}"

