# VVMA Kubernetes Deployment

A Kubernetes deployment for the VVMA (Very Vulnerable Management API) - a deliberately insecure RESTful API for educational and testing purposes.

## 🎯 Why Kubernetes for VVMA?

While VVMA can run with docker-compose, Kubernetes was chosen to model production-grade application deployment.

### Key benefits:
```
High availability & self-healing: Atomatic restarts and replica management keep the API running even when pods fail.

Scalability: Easily scale the API horizontally and lay the groundwork for autoscaling when needed.

Safe deployments: Rolling updates and built-in rollback support enable zero-downtime releases.

Infrastructure as Code: All infrastructure is defined as version-controlled YAML, enabling reproducible deployments and easy recovery.

Production-ready patterns: Uses Kubernetes primitives like Deployments, StatefulSets, Services, and resource limits to reflect real-world setups.
```

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
│   └── validate.sh                
├── Makefile                      
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