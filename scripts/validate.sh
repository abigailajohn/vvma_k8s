#!/bin/bash

set -e

echo "🔍 Validating Kubernetes YAML files..."
echo "" 

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

validate_yaml() {
    local file=$1
    echo -n "Checking $file... "
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}FAIL${NC} - File not found"
        ((ERRORS++))
        return 1
    fi
    
    if kubectl apply --dry-run=client -f "$file" &>/dev/null; then
        echo -e "${GREEN}OK${NC}"
        return 0
    else
        echo -e "${RED}FAIL${NC}"
        kubectl apply --dry-run=client -f "$file" 2>&1 | head -n 5
        ((ERRORS++))
        return 1
    fi
}

echo "=== Validating Namespace ==="
validate_yaml "k8s/base/namespace.yaml"
echo ""

echo "=== Validating MySQL Resources ==="
for file in k8s/base/mysql/*.yaml; do
    validate_yaml "$file"
done
echo ""

echo "=== Validating API Resources ==="
for file in k8s/base/api/*.yaml; do
    validate_yaml "$file"
done
echo ""

echo "=== Validating MailHog Resources ==="
for file in k8s/base/mailhog/*.yaml; do
    validate_yaml "$file"
done
echo ""

echo "=== Checking for Common Issues ==="

echo -n "Checking for committed secret files... "
SECRET_FILES=$(find k8s/ -name "secret.yaml" 2>/dev/null)
if [ -n "$SECRET_FILES" ]; then
    echo -e "${YELLOW}WARNING${NC} - Secret files found locally (make sure they are in .gitignore)"
else
    echo -e "${GREEN}OK${NC} - No secret files found"
fi

echo -n "Checking for proper labels... "
LABEL_COUNT=$(grep -r "app:" k8s/base/ | wc -l)
if [ "$LABEL_COUNT" -gt 10 ]; then
    echo -e "${GREEN}OK${NC} - Found $LABEL_COUNT app labels"
else
    echo -e "${YELLOW}WARNING${NC} - Only found $LABEL_COUNT app labels"
fi

echo ""
echo "==================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $ERRORS error(s)${NC}"
    exit 1
fi