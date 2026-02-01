#!/bin/bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   VVMA Kubernetes Deployment         ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════╝${NC}"
echo ""

if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed"
    exit 1
fi

echo "🔍 Checking cluster connection..."
if ! kubectl cluster-info &>/dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi
echo -e "${GREEN}✓${NC} Connected to cluster"
echo ""

echo "📦 Creating namespace..."
kubectl apply -f k8s/base/namespace.yaml
echo ""

echo "Deploying MySQL..."
kubectl apply -f k8s/base/mysql/
echo "⏳ Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n vvma --timeout=120s 2>/dev/null || {
    echo -e "${YELLOW}⚠️  MySQL is taking longer than expected...${NC}"
    echo "You can check status with: kubectl get pods -n vvma -w"
}
echo ""

echo "Deploying MailHog..."
kubectl apply -f k8s/base/mailhog/
echo ""

echo "Deploying API..."
kubectl apply -f k8s/base/api/
echo "⏳ Waiting for API to be ready..."
kubectl wait --for=condition=ready pod -l app=vvma-api -n vvma --timeout=120s 2>/dev/null || {
    echo -e "${YELLOW}⚠️  API is taking longer than expected...${NC}"
    echo "You can check status with: kubectl get pods -n vvma -w"
}
echo ""

echo -e "${GREEN}✅ Deployment complete!${NC}"
echo ""
echo "=== Deployment Status ==="
kubectl get all -n vvma
echo ""

echo "=== Access Instructions ==="
echo ""
echo "1. API Service:"
echo "   kubectl get svc vvma-api-service -n vvma"
echo ""
echo "2. MailHog UI (for testing emails):"
echo "   kubectl port-forward -n vvma svc/mailhog 8025:8025"
echo "   Then open: http://localhost:8025"
echo ""
echo "3. View logs:"
echo "   kubectl logs -n vvma -l app=vvma-api -f"
echo ""
echo "4. Scale API:"
echo "   kubectl scale deployment vvma-api -n vvma --replicas=3"
echo ""

echo -e "${GREEN}Happy Kubernetes learning!${NC}"