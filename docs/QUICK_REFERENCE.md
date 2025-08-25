# Quick Reference: Containerized Deployment Workflow

## 🚀 Essential Commands

### Docker-First Development
```bash
# Never install on host - always use Docker
docker run --rm -v $(pwd):/app -w /app node:18 npm install
docker run --rm -v $(pwd):/app -w /app python:3.11 pip install -r requirements.txt
```

### Kubernetes Debugging
```bash
# Check pod status (start with single replicas)
kubectl get pods -n app-namespace

# Debug pod issues
kubectl describe pod <pod-name> -n app-namespace
kubectl logs <pod-name> -n app-namespace

# Port forward for direct testing
kubectl port-forward pod/<pod-name> 8080:80 -n app-namespace
```

### DNS & SSL Troubleshooting
```bash
# Check DNS resolution
nslookup app.yourdomain.com
dig app.yourdomain.com

# Test application access
curl -H "Host: app.yourdomain.com" http://WAN_IP/
curl -I http://app.yourdomain.com/

# Check SSL certificate status
kubectl get certificates -n app-namespace
kubectl get challenges -n app-namespace
```

## 🔧 Critical Configurations

### Single Replica Start (Always)
```yaml
spec:
  replicas: 1  # Start with single replica for debugging
```

### SSL Challenge Configuration
```yaml
annotations:
  nginx.ingress.kubernetes.io/ssl-redirect: "false"      # Disable for ACME
  nginx.ingress.kubernetes.io/force-ssl-redirect: "false" # Disable for ACME
  cert-manager.io/cluster-issuer: "letsencrypt-prod"
```

### Image Pull Secrets
```yaml
spec:
  imagePullSecrets:
  - name: regcred  # Required for private Docker Hub repos
```

## 📋 Deployment Checklist

### Pre-Deployment
- [ ] DNS A record → WAN IP
- [ ] Cloudflare → "DNS only" (gray cloud)
- [ ] Docker Hub repos created
- [ ] GitHub secrets: `DOCKERHUB_USER`, `DOCKERHUB_TOKEN`
- [ ] ArgoCD app created

### Post-Deployment
- [ ] Pods running (1/1 Ready)
- [ ] Services created
- [ ] Ingress configured
- [ ] Application accessible via HTTP
- [ ] SSL certificate issued

## 🚨 Common Issues

### ImagePullBackOff
```bash
# Check Docker Hub credentials
kubectl get secret regcred -n app-namespace -o yaml

# Verify image tags match
kubectl describe pod <pod-name> -n app-namespace
```

### 522/Connection Errors
```bash
# Check ingress controller
kubectl get pods -n ingress-nginx

# Test direct pod access
kubectl port-forward pod/<pod-name> 8080:80 -n app-namespace
curl http://localhost:8080/
```

### SSL Certificate Issues
```bash
# Delete and recreate certificate
kubectl delete certificate app-tls -n app-namespace
kubectl apply -f k8s/ingress.yaml

# Check ACME challenges
kubectl get challenges -n app-namespace
kubectl describe challenge <challenge-name> -n app-namespace
```

## 🎯 Key Success Factors

1. **Single Replica Start** - Easier debugging
2. **DNS Resolution** - Must point to WAN IP
3. **Cloudflare Settings** - "DNS only" mode
4. **Image Pull Secrets** - For private repos
5. **SSL Redirect Disabled** - For ACME challenges
6. **Health Checks** - Proper liveness/readiness probes
7. **Resource Limits** - Prevent resource issues

## 📁 Essential Files

```
project-name/
├── k8s/
│   ├── namespace.yaml
│   ├── deployment.yaml (replicas: 1)
│   ├── service.yaml
│   └── ingress.yaml (SSL disabled for ACME)
├── .github/workflows/ci-cd.yml
├── argocd/app-name-app.yaml
└── scripts/setup-repo.sh
```

## 🔄 Workflow Summary

1. **Docker Development** → 2. **GitHub Actions** → 3. **Docker Hub** → 4. **ArgoCD** → 5. **Kubernetes**

**Remember**: Never pollute the host environment - everything in containers!
