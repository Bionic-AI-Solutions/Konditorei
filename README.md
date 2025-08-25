# Konditorei Cafe - AI-Powered Landing Page

A React-based web application that hosts the ElevenLabs Convai widget, designed for deployment on Kubernetes clusters through ArgoCD. This project replicates the [Konditorei Cafe](https://konditoreicafe.com/) website with integrated AI assistance.

## 🚀 Features

- **Modern React Application**: Built with React 18 and modern web technologies
- **ElevenLabs Convai Integration**: Embedded conversational AI widget
- **Docker Containerization**: Fully containerized for easy deployment
- **Kubernetes Ready**: Complete K8s manifests for production deployment
- **ArgoCD Integration**: GitOps deployment with ArgoCD
- **SSL/TLS Support**: Automatic SSL certificate management
- **High Availability**: Multi-replica deployment with health checks
- **Responsive Design**: Beautiful, modern UI that works on all devices

## 📋 Prerequisites

- Docker and Docker Compose
- Kubernetes cluster (for production deployment)
- ArgoCD (for GitOps deployment)
- kubectl CLI tool
- ArgoCD CLI (optional but recommended)

## 🏗️ Project Structure

```
konditorei/
├── frontend/                 # React application
│   ├── public/              # Static assets
│   ├── src/                 # React source code
│   ├── Dockerfile           # Frontend container
│   └── nginx.conf           # Nginx configuration
├── backend/                 # FastAPI backend
│   ├── main.py             # API endpoints
│   ├── requirements.txt    # Python dependencies
│   └── Dockerfile          # Backend container
├── k8s/                     # Kubernetes manifests
│   ├── namespace.yaml       # K8s namespace
│   ├── deployment.yaml      # Frontend deployment
│   ├── service.yaml         # K8s service
│   ├── ingress.yaml         # Ingress configuration
│   └── configmap.yaml       # Environment configuration
├── argocd/                  # ArgoCD configuration
│   └── konditorei-app.yaml  # ArgoCD application
├── scripts/                 # Build and deployment scripts
│   ├── build.sh            # Docker build script
│   ├── deploy.sh           # K8s deployment script
│   └── test.sh             # Testing script
├── .github/                 # GitHub Actions
│   └── workflows/          # CI/CD pipelines
├── docker-compose.yml       # Local development
├── docker-compose.prod.yml  # Production setup
└── README.md               # This file
```

## 🚀 Quick Start

### Isolated Development Environment

This project uses Docker to provide a clean, isolated development environment that won't pollute your host system.

1. **Clone the repository**
   ```bash
   git clone https://github.com/Bionic-AI-Solutions/Konditorei.git
   cd Konditorei
   ```

2. **Start isolated development environment**
   ```bash
   ./scripts/dev-setup.sh start
   ```

3. **Access the application**
   - Open http://localhost:3000 in your browser
   - The ElevenLabs Convai widget will appear in the bottom right corner

4. **Clean up when done**
   ```bash
   ./scripts/dev-setup.sh clean
   ```

### Production Build (Isolated)

1. **Build everything in clean Docker environment**
   ```bash
   ./scripts/isolated-build.sh
   ```

2. **Or use the development setup**
   ```bash
   ./scripts/dev-setup.sh build
   ```

## 🐳 Docker Deployment

### Isolated Development Environment

```bash
# Start development environment (clean, isolated)
./scripts/dev-setup.sh start

# Build production image (isolated)
./scripts/dev-setup.sh build

# Run tests (isolated)
./scripts/dev-setup.sh test

# Clean up everything
./scripts/dev-setup.sh clean
```

### Production Docker Compose

```bash
# Production deployment
docker-compose -f docker-compose.prod.yml up -d
```

## ☸️ Kubernetes Deployment

### Prerequisites

- Kubernetes cluster with ingress controller
- cert-manager for SSL certificates
- ArgoCD for GitOps deployment

### Deploy to Kubernetes

1. **Apply Kubernetes manifests**
   ```bash
   ./scripts/deploy.sh
   ```

2. **Verify deployment**
   ```bash
   kubectl get pods -n konditorei
   kubectl get services -n konditorei
   kubectl get ingress -n konditorei
   ```

### ArgoCD Deployment

1. **Update the ArgoCD application manifest**
   - Edit `argocd/konditorei-app.yaml`
   - Update the `repoURL` to point to your Git repository

2. **Apply ArgoCD application**
   ```bash
   kubectl apply -f argocd/konditorei-app.yaml
   ```

3. **Sync the application**
   ```bash
   argocd app sync konditorei-widget
   ```

## 🔧 Configuration

### Environment Variables

The application can be configured through environment variables:

- `REACT_APP_ENVIRONMENT`: Application environment (development/production)
- `REACT_APP_API_URL`: API endpoint URL
- `REACT_APP_WIDGET_AGENT_ID`: ElevenLabs Convai agent ID

### Kubernetes Configuration

Update the ConfigMap in `k8s/configmap.yaml` to modify environment variables:

```yaml
data:
  REACT_APP_ENVIRONMENT: "production"
  REACT_APP_API_URL: "https://konditorei.bionicaisolutions.com/api"
  REACT_APP_WIDGET_AGENT_ID: "agent_6401k3d96afze6cbtcx585yqa3sa"
```

## 🧪 Testing

### Run Tests (Isolated Environment)

```bash
# Test in isolated development environment
./scripts/dev-setup.sh test

# Or run comprehensive tests
./scripts/test.sh all
```

## 📊 Monitoring

### Health Checks

The application includes health check endpoints:
- `/health` - Basic health status

### Logs

```bash
# Docker logs
docker-compose logs -f konditorei-frontend

# Kubernetes logs
kubectl logs -f deployment/konditorei-frontend -n konditorei
```

## 🔒 Security

### SSL/TLS

The application is configured with:
- Automatic SSL certificate management via cert-manager
- HTTPS redirect
- Security headers

### Security Headers

The nginx configuration includes:
- X-Frame-Options
- X-XSS-Protection
- X-Content-Type-Options
- Referrer-Policy
- Content-Security-Policy

## 🚀 Scaling

### Horizontal Pod Autoscaling

Add HPA for automatic scaling:

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: konditorei-frontend-hpa
  namespace: konditorei
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: konditorei-frontend
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## 🐛 Troubleshooting

### Common Issues

1. **Widget not loading**
   - Check if the ElevenLabs script is accessible
   - Verify the agent ID is correct
   - Check browser console for errors

2. **Docker build fails**
   - Ensure Docker is running
   - Check available disk space
   - Verify network connectivity

3. **Kubernetes deployment issues**
   - Check pod logs: `kubectl logs -n konditorei`
   - Verify ingress controller is installed
   - Check certificate manager status

### Debug Commands

```bash
# Check pod status
kubectl get pods -n konditorei

# Check pod logs
kubectl logs -f deployment/konditorei-frontend -n konditorei

# Check ingress status
kubectl describe ingress konditorei-ingress -n konditorei

# Check ArgoCD application status
argocd app get konditorei-widget
```

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the troubleshooting section

## 🏢 About Bionic AI Solutions

This project is maintained by [Bionic AI Solutions](https://github.com/Bionic-AI-Solutions), a leading provider of AI-powered solutions and intelligent applications.
# Test commit for CI/CD pipeline
