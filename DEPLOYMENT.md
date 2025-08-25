# 🚀 Konditorei Deployment Guide

This guide will walk you through the complete deployment process for the Konditorei Cafe AI-powered landing page.

## 📋 Prerequisites

Before starting, ensure you have:

- [ ] GitHub account with access to [Bionic-AI-Solutions](https://github.com/Bionic-AI-Solutions) organization
- [ ] Docker Hub account
- [ ] Kubernetes cluster with ArgoCD installed
- [ ] kubectl configured to access your cluster
- [ ] ArgoCD CLI (optional but recommended)

## 🔧 Step 1: Repository Setup

### 1.1 Initialize Git Repository

```bash
# Run the setup script
./scripts/setup-repo.sh
```

### 1.2 Create GitHub Repository

1. Go to https://github.com/Bionic-AI-Solutions
2. Click "New repository"
3. Repository name: `Konditorei`
4. Description: `AI-powered landing page for Konditorei Cafe`
5. Make it **Public**
6. **Don't** initialize with README (we already have one)
7. Click "Create repository"

### 1.3 Push to GitHub

```bash
# Add remote and push
git remote add origin https://github.com/Bionic-AI-Solutions/Konditorei.git
git branch -M main
git push -u origin main
```

## 🔐 Step 2: GitHub Secrets Setup

### 2.1 Docker Hub Credentials

1. Go to your GitHub repository settings
2. Navigate to "Secrets and variables" → "Actions"
3. Add the following secrets:

**DOCKERHUB_USER**
- Your Docker Hub username

**DOCKERHUB_TOKEN**
- Your Docker Hub access token (create one at https://hub.docker.com/settings/security)

### 2.2 Kubernetes Configuration

**KUBE_CONFIG**
- Base64 encoded kubeconfig for your cluster
- Generate with: `cat ~/.kube/config | base64 -w 0`

## 🐳 Step 3: Docker Hub Setup

### 3.1 Create Docker Hub Repository

1. Go to https://hub.docker.com
2. Create a new repository named `bionicaisolutions/konditorei`
3. Make it public

### 3.2 Test Docker Build Locally

```bash
# Build frontend image
docker build -t bionicaisolutions/konditorei:latest ./frontend

# Build backend image
docker build -t bionicaisolutions/konditorei-backend:latest ./backend

# Test images locally
docker run -p 3000:80 bionicaisolutions/konditorei:latest
docker run -p 8000:8000 bionicaisolutions/konditorei-backend:latest
```

## ☸️ Step 4: Kubernetes Deployment

### 4.1 Create Namespace

```bash
# Apply namespace
kubectl apply -f k8s/namespace.yaml

# Verify namespace creation
kubectl get namespace ChatBots
```

### 4.2 Deploy Application

```bash
# Apply all Kubernetes manifests
kubectl apply -f k8s/

# Verify deployment
kubectl get pods -n ChatBots
kubectl get services -n ChatBots
kubectl get ingress -n ChatBots
```

### 4.3 Check Application Status

```bash
# Check pod status
kubectl get pods -n ChatBots

# Check service endpoints
kubectl get endpoints -n ChatBots

# Check ingress
kubectl describe ingress konditorei-ingress -n ChatBots
```

## 🔄 Step 5: ArgoCD Deployment

### 5.1 Deploy ArgoCD Application

```bash
# Apply ArgoCD application
kubectl apply -f argocd/konditorei-app.yaml

# Verify ArgoCD application
argocd app get Konditorei
```

### 5.2 Sync Application

```bash
# Sync the application
argocd app sync Konditorei

# Wait for sync to complete
argocd app wait Konditorei --health --timeout 300
```

### 5.3 Monitor Deployment

```bash
# Check application status
argocd app list

# View application details
argocd app get Konditorei
```

## 🌐 Step 6: DNS Configuration

### 6.1 Configure DNS

Ensure your DNS points `konditorei.bionicaisolutions.com` to your ingress controller's external IP:

```bash
# Get ingress external IP
kubectl get ingress konditorei-ingress -n ChatBots -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

### 6.2 SSL Certificate

The ingress is configured to automatically request SSL certificates via cert-manager. Verify certificate status:

```bash
# Check certificate status
kubectl get certificates -n ChatBots
kubectl describe certificate konditorei-tls -n ChatBots
```

## 🧪 Step 7: Testing

### 7.1 Health Checks

```bash
# Test frontend health
curl -f https://konditorei.bionicaisolutions.com/health

# Test backend health
curl -f https://konditorei.bionicaisolutions.com/api/health
```

### 7.2 Application Testing

1. Open https://konditorei.bionicaisolutions.com in your browser
2. Verify the Konditorei Cafe landing page loads correctly
3. Test the ElevenLabs Convai widget in the bottom-right corner
4. Verify all menu items and sections display properly

## 📊 Step 8: Monitoring

### 8.1 Application Logs

```bash
# Frontend logs
kubectl logs -f deployment/konditorei-frontend -n ChatBots

# Backend logs
kubectl logs -f deployment/konditorei-backend -n ChatBots
```

### 8.2 Resource Usage

```bash
# Check resource usage
kubectl top pods -n ChatBots

# Check node resource usage
kubectl top nodes
```

## 🔄 Step 9: CI/CD Pipeline

### 9.1 Trigger Deployment

The GitHub Actions pipeline will automatically:

1. **Test**: Run unit tests and build verification
2. **Build**: Create Docker images
3. **Push**: Push images to Docker Hub
4. **Deploy**: Update Kubernetes deployment

### 9.2 Manual Trigger

To manually trigger the pipeline:

1. Go to your GitHub repository
2. Navigate to "Actions"
3. Select "CI/CD Pipeline"
4. Click "Run workflow"

## 🚨 Troubleshooting

### Common Issues

1. **Image Pull Errors**
   ```bash
   # Check image pull secrets
   kubectl get secrets -n ChatBots
   kubectl describe pod <pod-name> -n ChatBots
   ```

2. **Ingress Not Working**
   ```bash
   # Check ingress controller
   kubectl get pods -n ingress-nginx
   kubectl describe ingress konditorei-ingress -n ChatBots
   ```

3. **SSL Certificate Issues**
   ```bash
   # Check cert-manager
   kubectl get pods -n cert-manager
   kubectl describe certificate konditorei-tls -n ChatBots
   ```

4. **ArgoCD Sync Issues**
   ```bash
   # Check ArgoCD application
   argocd app get Konditorei
   argocd app logs Konditorei
   ```

### Debug Commands

```bash
# Get all resources in namespace
kubectl get all -n ChatBots

# Describe specific resource
kubectl describe <resource-type> <resource-name> -n ChatBots

# Check events
kubectl get events -n ChatBots --sort-by='.lastTimestamp'

# Port forward for debugging
kubectl port-forward svc/konditorei-frontend-service 3000:80 -n ChatBots
```

## 🎉 Success!

Once all steps are completed, your Konditorei Cafe AI-powered landing page will be:

- ✅ Running on Kubernetes in the ChatBots namespace
- ✅ Accessible at https://konditorei.bionicaisolutions.com
- ✅ Protected with SSL/TLS
- ✅ Integrated with ElevenLabs Convai widget
- ✅ Managed by ArgoCD for GitOps
- ✅ Automatically updated via GitHub Actions

## 📞 Support

If you encounter any issues:

1. Check the troubleshooting section above
2. Review application logs
3. Verify all prerequisites are met
4. Contact the development team

---

**Happy Deploying! 🚀**
