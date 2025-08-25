# Cursor Instructions: Containerized App Deployment Workflow

## Overview
This instruction set enables Cursor to create containerized applications with GitHub Actions CI/CD, Kubernetes manifests, and ArgoCD deployment while keeping the host environment clean.

## Core Principles
1. **Host Environment Protection**: Never install dependencies directly on host
2. **Docker-First Development**: All builds, tests, and package management in containers
3. **GitOps Workflow**: GitHub Actions → Docker Hub → ArgoCD → Kubernetes
4. **Single Replica Debugging**: Start with single replicas for easier troubleshooting

## Project Structure Template
```
project-name/
├── frontend/                 # React frontend
│   ├── public/
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── backend/                  # FastAPI/Node.js backend (optional)
│   ├── app/
│   ├── requirements.txt
│   └── Dockerfile
├── k8s/                      # Kubernetes manifests
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── backend-deployment.yaml
│   ├── service.yaml
│   ├── backend-service.yaml
│   └── ingress.yaml
├── argocd/                   # ArgoCD application
│   └── app-name-app.yaml
├── .github/workflows/        # GitHub Actions
│   └── ci-cd.yml
├── scripts/                  # Helper scripts
│   ├── setup-repo.sh
│   └── simple-dockerhub-setup.sh
├── docker-compose.yml        # Local development
├── .gitignore
└── README.md
```

## Step-by-Step Implementation

### 1. Initial Setup (Always Use Docker)
```bash
# Create project directory
mkdir project-name && cd project-name

# Use Docker for all package management
docker run --rm -v $(pwd):/app -w /app node:18 npm create react-app frontend
docker run --rm -v $(pwd):/app -w /app python:3.11 pip install fastapi uvicorn
```

### 2. Frontend Setup (React)
```javascript
// frontend/package.json - Add to dependencies
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  }
}

// frontend/Dockerfile
FROM node:18-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 3. Backend Setup (FastAPI)
```python
# backend/main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.get("/")
async def root():
    return {"message": "Backend API"}
```

```dockerfile
# backend/Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 4. Kubernetes Manifests

#### Namespace
```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: app-namespace
  labels:
    name: app-namespace
```

#### Frontend Deployment (Single Replica for Debugging)
```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-frontend
  namespace: app-namespace
  labels:
    app: app-frontend
    version: v1
spec:
  replicas: 1  # Start with single replica
  selector:
    matchLabels:
      app: app-frontend
  template:
    metadata:
      labels:
        app: app-frontend
        version: v1
    spec:
      containers:
      - name: frontend
        image: dockerhub-username/app-name:main
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
      imagePullSecrets:
      - name: regcred
```

#### Backend Deployment
```yaml
# k8s/backend-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-backend
  namespace: app-namespace
  labels:
    app: app-backend
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-backend
  template:
    metadata:
      labels:
        app: app-backend
        version: v1
    spec:
      containers:
      - name: backend
        image: dockerhub-username/app-name-backend:main
        ports:
        - containerPort: 8000
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
      imagePullSecrets:
      - name: regcred
```

#### Services
```yaml
# k8s/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: app-frontend-service
  namespace: app-namespace
  labels:
    app: app-frontend
spec:
  selector:
    app: app-frontend
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  type: ClusterIP
```

```yaml
# k8s/backend-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: app-backend-service
  namespace: app-namespace
  labels:
    app: app-backend
spec:
  selector:
    app: app-backend
  ports:
  - port: 8000
    targetPort: 8000
    protocol: TCP
  type: ClusterIP
```

#### Ingress (SSL Enabled)
```yaml
# k8s/ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: app-namespace
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"  # Disable for ACME challenge
    nginx.ingress.kubernetes.io/force-ssl-redirect: "false"  # Disable for ACME challenge
    nginx.ingress.kubernetes.io/proxy-body-size: "50m"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "30"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  labels:
    app: app-frontend
spec:
  tls:
  - hosts:
    - app.yourdomain.com
    secretName: app-tls
  rules:
  - host: app.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-frontend-service
            port:
              number: 80
```

### 5. GitHub Actions CI/CD
```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  IMAGE_NAME: dockerhub-username/app-name
  BACKEND_IMAGE_NAME: dockerhub-username/app-name-backend

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    
    - name: Test Frontend
      run: |
        docker run --rm -v $(pwd)/frontend:/app -w /app node:18 npm ci
        docker run --rm -v $(pwd)/frontend:/app -w /app node:18 npm test -- --passWithNoTests
    
    - name: Test Backend
      run: |
        docker run --rm -v $(pwd)/backend:/app -w /app python:3.11 pip install -r requirements.txt
        docker run --rm -v $(pwd)/backend:/app -w /app python:3.11 python -m pytest

  build-and-push:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3
    
    - name: Login to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKERHUB_USER }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
    
    - name: Build and push Frontend
      uses: docker/build-push-action@v5
      with:
        context: ./frontend
        push: true
        tags: ${{ env.IMAGE_NAME }}:${{ github.sha }}, ${{ env.IMAGE_NAME }}:main
        cache-from: type=gha
        cache-to: type=gha,mode=max
    
    - name: Build and push Backend
      uses: docker/build-push-action@v5
      with:
        context: ./backend
        push: true
        tags: ${{ env.BACKEND_IMAGE_NAME }}:${{ github.sha }}, ${{ env.BACKEND_IMAGE_NAME }}:main
        cache-from: type=gha
        cache-to: type=gha,mode=max

  notify:
    needs: [test, build-and-push]
    runs-on: ubuntu-latest
    if: always()
    steps:
    - name: Notify Success
      if: success()
      run: |
        echo "✅ All tests passed and Docker images pushed successfully!"
        echo "🚀 ArgoCD will automatically deploy to Kubernetes"
    
    - name: Notify Failure
      if: failure()
      run: |
        echo "❌ Pipeline failed - check the logs above"
```

### 6. ArgoCD Application
```yaml
# argocd/app-name-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: app-name
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: https://github.com/your-org/project-name.git
    targetRevision: main
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: app-namespace
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

### 7. Helper Scripts

#### Repository Setup
```bash
# scripts/setup-repo.sh
#!/bin/bash

# Initialize git repository
git init
git add .
git commit -m "Initial commit: Containerized app setup"

echo "✅ Repository initialized successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Create GitHub repository: https://github.com/your-org/project-name"
echo "2. Add remote: git remote add origin https://github.com/your-org/project-name.git"
echo "3. Push: git push -u origin main"
echo "4. Set up GitHub secrets: DOCKERHUB_USER, DOCKERHUB_TOKEN"
echo "5. Create Docker Hub repositories"
echo "6. Apply ArgoCD application"
```

#### Docker Hub Setup
```bash
# scripts/simple-dockerhub-setup.sh
#!/bin/bash

echo "🐳 Docker Hub Repository Setup Instructions"
echo ""
echo "1. Go to https://hub.docker.com/"
echo "2. Create repositories:"
echo "   - app-name (for frontend)"
echo "   - app-name-backend (for backend)"
echo "3. Set repositories to private if needed"
echo "4. Update IMAGE_NAME in .github/workflows/ci-cd.yml"
echo "5. Update image references in k8s/*.yaml files"
```

### 8. Local Development (Docker Compose)
```yaml
# docker-compose.yml
version: '3.8'

services:
  frontend-dev:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
    command: npm start

  backend-dev:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    ports:
      - "8000:8000"
    volumes:
      - ./backend:/app
    environment:
      - ENV=development
    command: uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### 9. .gitignore
```gitignore
# Dependencies
node_modules/
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.env

# Build outputs
build/
dist/
*.egg-info/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Docker
.dockerignore

# Kubernetes
*.kubeconfig

# Logs
*.log
logs/

# Temporary files
temp/
docker-volumes/
```

### 10. Deployment Checklist

#### Pre-Deployment
- [ ] DNS A record points to WAN IP
- [ ] Cloudflare set to "DNS only" (gray cloud) if using Cloudflare
- [ ] Docker Hub repositories created
- [ ] GitHub secrets configured (DOCKERHUB_USER, DOCKERHUB_TOKEN)
- [ ] ArgoCD application created

#### Post-Deployment Verification
```bash
# Check pod status
kubectl get pods -n app-namespace

# Check services
kubectl get svc -n app-namespace

# Check ingress
kubectl get ingress -n app-namespace

# Test application
curl -H "Host: app.yourdomain.com" http://WAN_IP/

# Check SSL certificate
kubectl get certificates -n app-namespace
kubectl get challenges -n app-namespace
```

#### Troubleshooting Commands
```bash
# Debug pod issues
kubectl describe pod <pod-name> -n app-namespace
kubectl logs <pod-name> -n app-namespace

# Check ingress controller
kubectl get pods -n ingress-nginx

# Test DNS resolution
nslookup app.yourdomain.com
dig app.yourdomain.com

# Port forward for direct testing
kubectl port-forward pod/<pod-name> 8080:80 -n app-namespace
```

## Key Success Factors

1. **Single Replica Start**: Always begin with single replicas for easier debugging
2. **DNS Configuration**: Ensure proper DNS resolution before SSL certificate issuance
3. **Cloudflare Settings**: Set to "DNS only" mode to avoid ACME challenge issues
4. **Image Pull Secrets**: Configure regcred secret for private Docker Hub repositories
5. **Resource Limits**: Set appropriate CPU/memory limits to prevent resource issues
6. **Health Checks**: Implement proper liveness and readiness probes
7. **SSL Configuration**: Start with SSL redirect disabled for ACME challenges

## Common Issues and Solutions

### ImagePullBackOff
- Verify Docker Hub credentials in regcred secret
- Check image tags match between CI/CD and Kubernetes manifests
- Ensure repository exists and is accessible

### SSL Certificate Issues
- Verify DNS resolves to WAN IP, not Cloudflare IPs
- Check ACME challenge endpoints are accessible
- Ensure ingress annotations allow HTTP access for challenges

### 522/Connection Errors
- Verify ingress controller is running
- Check pod health and readiness
- Test direct pod access via port-forward

This workflow ensures clean, reproducible deployments while maintaining host environment integrity.
