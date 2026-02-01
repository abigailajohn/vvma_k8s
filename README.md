# VVMA Kubernetes Deployment

A Kubernetes deployment for the VVMA (Very Vulnerable Management API) - a deliberately insecure RESTful API for educational and testing purposes.

## 🎯 Why Kubernetes for VVMA?

While VVMA could run with `docker-compose`, Kubernetes provides enterprise-grade benefits:

### High Availability & Self-Healing
- **Automatic Recovery**: If the API crashes, Kubernetes restarts it within seconds
- **Pod Distribution**: Run multiple replicas across different nodes for redundancy

### Scalability
- **Horizontal Scaling**: Scale from 1 to 100 API replicas with a single command
- **Resource Efficiency**: Pack workloads efficiently across your cluster
- **Auto-scaling Ready**: Foundation for HPA (Horizontal Pod Autoscaler) when needed

### Operational Excellence
- **Zero-Downtime Deployments**: Rolling updates ensure continuous availability
- **Rollback Safety**: Instantly revert to previous versions if issues arise
- **Secret Management**: Secure handling of credentials and sensitive data

### Infrastructure as Code
- **Version Control**: Your entire infrastructure is Git-managed YAML
- **Reproducibility**: Identical deployments across any Kubernetes cluster
- **Audit Trail**: Track who changed what and when
- **Disaster Recovery**: Rebuild your entire stack from YAML files

### Production-Ready Patterns
- **StatefulSets**: Stable MySQL storage that survives pod restarts
- **Service Discovery**: Components find each other by name, not brittle IP addresses
- **Resource Limits**: Prevent resource starvation and ensure fair sharing
- **Security Contexts**: Run containers with minimal privileges

## 📁 Project Structure

```
vvma-k8s/
├── k8s/
│   └── base/                      # Base Kubernetes manifests
│       ├── namespace.yaml         # Namespace isolation
│       ├── mysql/                 # MySQL StatefulSet
│       │   ├── statefulset.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   ├── secret.yaml
│       │   └── pvc.yaml
│       ├── api/                   # API deployment
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── secret.yaml
│       └── mailhog/               # MailHog deployment
│           ├── deployment.yaml
│           └── service.yaml
├── .github/
│   └── workflows/
│       └── validate.yaml          # CI/CD
├── scripts/
│   ├── deploy.sh                  # Deployment script
│   └── validate.sh                # Pre-deployment validation
├── Makefile                       # Convenient commands
└── README.md                     
```

## 🚀 Quick Start

### Prerequisites
- Kubernetes cluster (minikube, kind, or cloud provider)
- `kubectl` configured and connected to your cluster

### Deploy Everything

```bash
# Deploy all resources
make deploy

# Or manually:
kubectl apply -f k8s/base/namespace.yaml
kubectl apply -f k8s/base/mysql/
kubectl apply -f k8s/base/mailhog/
kubectl apply -f k8s/base/api/
```

### Verify Deployment

```bash
# Check all resources
make status

# get pods
kubectl get pods -n vvma

# Check services
kubectl get svc -n vvma
```

### Access the Application

```bash
# Get the API service URL
kubectl get svc vvma-api-service -n vvma

# Access MailHog UI
kubectl port-forward -n vvma svc/mailhog 8025:8025
```
## 🔒 Security Notes

**⚠️ This configuration is for DEVELOPMENT/LEARNING purposes**

For production:
- [ ] Replace hardcoded passwords with proper secret management (Sealed Secrets, External Secrets Operator)
- [ ] Enable Network Policies to restrict pod communication
- [ ] Add RBAC (Role-Based Access Control)
- [ ] Use SecurityContexts with non-root users
- [ ] Implement resource quotas and limit ranges
- [ ] Enable Pod Security Standards
- [ ] Use TLS/SSL for MySQL connections
- [ ] Configure backup and disaster recovery

## 📊 Architecture

```
┌─────────────────────────────────────────────┐
│           Kubernetes Cluster                │
│  ┌───────────────────────────────────────┐  │
│  │      Namespace: vvma                  │  │
│  │                                       │  │
│  │  ┌──────────┐      ┌──────────────┐   │  │
│  │  │   API    │────▶|    MySQL      │  │  │
│  │  │Deployment│      │ StatefulSet  │   │  │
│  │  │(Replicas)│      │              │   │  │
│  │  └────┬─────┘      └──────────────┘   │  │
│  │       │                               │  │
│  │       │            ┌──────────────┐   │  │
│  │       └───────────▶│   MailHog    │   │  │
│  │                    │  Deployment  │   │  │
│  │                    │              │   │  │
│  │                    └──────────────┘   │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

## 🤝 Contributing

This is a learning project! Feel free to:
- Open issues for questions or improvements
- Submit PRs
- Share your own Kubernetes learning journey

## 📚 Learning Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [12 Factor Apps](https://12factor.net/)

## 📝 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

Built as a learning project to understand Kubernetes fundamentals including:
- Deployments, StatefulSets, and Services
- ConfigMaps and Secrets management
- Persistent storage with PVCs
- Multi-tier application deployment
- Container orchestration patterns

---

**Note**: This project demonstrates Kubernetes concepts with raw YAML manifests.