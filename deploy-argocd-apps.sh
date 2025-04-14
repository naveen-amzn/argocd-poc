#!/bin/bash

# Set your repo and branch
REPO_URL="https://github.com/pradippandey29/argocd-poc.git"
TARGET_REVISION="HEAD"
APP_PATH="env"

# Create namespaces
kubectl create namespace stage --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f -

# Create Argo CD Applications
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: demo-app-stage
  namespace: argocd
spec:
  project: default
  source:
    repoURL: "$REPO_URL"
    targetRevision: "$TARGET_REVISION"
    path: "$APP_PATH"
    helm:
      valueFiles:
        - values-stage.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: stage
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: demo-app-prod
  namespace: argocd
spec:
  project: default
  source:
    repoURL: "$REPO_URL"
    targetRevision: "$TARGET_REVISION"
    path: "$APP_PATH"
    helm:
      valueFiles:
        - values-prod.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: prod
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

## ./deploy-argocd-apps.sh
