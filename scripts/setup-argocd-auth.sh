#!/bin/bash

# Script to set up ArgoCD authentication for private GitHub repository
# Usage: ./setup-argocd-auth.sh <GITHUB_TOKEN>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <GITHUB_TOKEN>"
    echo "Please provide your GitHub token as an argument"
    exit 1
fi

GITHUB_TOKEN=$1

echo "Setting up ArgoCD authentication for Konditorei repository..."

# Create the GitHub secret
echo "Creating GitHub secret..."
kubectl create secret generic konditorei-github-secret \
  --namespace=argocd \
  --from-literal=type=git \
  --from-literal=url=https://github.com/Bionic-AI-Solutions/Konditorei.git \
  --from-literal=username=not-used \
  --from-literal=password="$GITHUB_TOKEN" \
  --dry-run=client -o yaml | kubectl apply -f -

# Add the required label for ArgoCD to recognize it as a repository secret
kubectl label secret konditorei-github-secret -n argocd argocd.argoproj.io/secret-type=repository

echo "GitHub secret created successfully!"

# Apply the ArgoCD application
echo "Applying ArgoCD application..."
kubectl apply -f argocd/konditorei-app.yaml

echo "ArgoCD application applied successfully!"

# Wait a moment for ArgoCD to process the changes
echo "Waiting for ArgoCD to process changes..."
sleep 10

# Check the application status
echo "Checking application status..."
kubectl get application konditorei -n argocd

echo "Setup complete! Check ArgoCD UI or run 'kubectl get application konditorei -n argocd' to monitor status."
