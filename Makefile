.PHONY: help deploy delete status validate logs scale

# Default target
help:
	@echo "VVMA Kubernetes Deployment Commands"
	@echo "===================================="
	@echo "make deploy          - Deploy all resources to Kubernetes"
	@echo "make delete          - Delete all resources from Kubernetes"
	@echo "make status          - Show status of all resources"
	@echo "make validate        - Validate all YAML files"
	@echo "make logs-api        - Tail logs from API pods"
	@echo "make logs-mysql      - Tail logs from MySQL pod"
	@echo "make logs-mailhog    - Tail logs from MailHog pod"
	@echo "make scale           - Scale API to 3 replicas"

deploy:
	@echo "Deploying VVMA to Kubernetes..."
	kubectl apply -f k8s/base/namespace.yaml
	kubectl apply -f k8s/base/mysql/
	@echo "Waiting for MySQL to be ready..."
	kubectl wait --for=condition=ready pod -l app=mysql -n vvma --timeout=120s || true
	kubectl apply -f k8s/base/mailhog/
	kubectl apply -f k8s/base/api/
	@echo "Waiting for API to be ready..."
	kubectl wait --for=condition=ready pod -l app=vvma-api -n vvma --timeout=120s || true
	@echo ""
	@echo "✅ Deployment complete!"
	@echo ""
	@make status

delete:
	@echo "Deleting VVMA from Kubernetes..."
	kubectl delete -f k8s/base/api/ --ignore-not-found=true
	kubectl delete -f k8s/base/mailhog/ --ignore-not-found=true
	kubectl delete -f k8s/base/mysql/ --ignore-not-found=true
	kubectl delete -f k8s/base/namespace.yaml --ignore-not-found=true
	@echo "✅ All resources deleted!"

status:
	@echo "=== Namespace ==="
	kubectl get namespace vvma
	@echo ""
	@echo "=== Pods ==="
	kubectl get pods -n vvma -o wide
	@echo ""
	@echo "=== Services ==="
	kubectl get svc -n vvma
	@echo ""
	@echo "=== StatefulSets ==="
	kubectl get statefulsets -n vvma
	@echo ""
	@echo "=== Deployments ==="
	kubectl get deployments -n vvma
	@echo ""
	@echo "=== PVCs ==="
	kubectl get pvc -n vvma

validate:
	@./scripts/validate.sh

logs-api:
	kubectl logs -n vvma -l app=vvma-api -f --max-log-requests=10

logs-mysql:
	kubectl logs -n vvma -l app=mysql -f

logs-mailhog:
	kubectl logs -n vvma -l app=mailhog -f

scale:
	kubectl scale deployment vvma-api -n vvma --replicas=3
	@echo "Scaled API to 3 replicas"

restart-api:
	kubectl rollout restart deployment/vvma-api -n vvma
	@echo "API deployment restarted"

restart-mysql:
	kubectl delete pod -n vvma -l app=mysql
	@echo "MySQL pod deleted (will be recreated by StatefulSet)"