#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="${1:-}"
CLUSTER_NAME="${2:-}"
NAMESPACE="${3:-}"

if [[ -z "$RESOURCE_GROUP" || -z "$CLUSTER_NAME" || -z "$NAMESPACE" ]]; then
  echo "Usage: $0 <resource-group> <cluster-name> <namespace>"
  exit 2
fi

# Pull cluster credentials into kubeconfig so kubectl can connect.
az aks get-credentials \
  --resource-group "$RESOURCE_GROUP" \
  --name "$CLUSTER_NAME" \
  --overwrite-existing

kubectl get svc -n "$NAMESPACE"
kubectl describe svc frontend-public -n "$NAMESPACE"
kubectl get pods -n "$NAMESPACE" -o wide
kubectl get pods -n "$NAMESPACE" --field-selector=status.phase!=Running || true
kubectl get endpoints frontend-public -n "$NAMESPACE"
kubectl get endpointslices -n "$NAMESPACE" 2>/dev/null || true

kubectl describe deployment frontend -n "$NAMESPACE" || true
kubectl describe pod -n "$NAMESPACE" -l io.kompose.service=frontend || true
kubectl logs -n "$NAMESPACE" deploy/frontend --tail=200 || true
kubectl logs -n "$NAMESPACE" deploy/frontend --previous --tail=200 || true
kubectl get events -n "$NAMESPACE" --sort-by=.lastTimestamp | tail -n 50 || true

FRONTEND_ENDPOINT="$(kubectl get svc frontend-public -n "$NAMESPACE" -o jsonpath='{.status.loadBalancer.ingress[0].ip}{.status.loadBalancer.ingress[0].hostname}')"
if [[ -n "$FRONTEND_ENDPOINT" ]]; then
  echo "Frontend endpoint: $FRONTEND_ENDPOINT"
else
  echo "Frontend endpoint not assigned yet."
  exit 1
fi
