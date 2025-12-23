# Homelab K3s Infrastructure

## Bootstrap

### 1. ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/ingress.yaml

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### 2. CloudNativePG
```bash
kubectl apply --server-side -f \
  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.25/releases/cnpg-1.25.1.yaml
```

### 3. Kubernetes Dashboard
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl apply -f dashboard/admin-user.yaml

# Get token
kubectl -n kubernetes-dashboard create token admin-user
```

### 4. Prometheus Operator (via ArgoCD)
```bash
kubectl apply -f monitoring/prometheus-operator.yaml
```

### 5. Deploy apps
```bash
kubectl apply -f apps/
```

## Applications

| App | Namespace |
|-----|-----------|
| [sticker-bot](https://github.com/jaennil/quick-stickers-tg-bot) | sticker-bot |
| [vmservice](https://github.com/jaennil/vmservice) | vmservice |
| [guide-helper](https://github.com/jaennil/guide_helper) | guide-helper |
| webdav (Obsidian sync) | webdav |
| tuna (k8s.ru.tuna.am tunnel) | tuna |

## WebDAV Setup

```bash
cp webdav/secret.yaml.example webdav/secret.yaml
# Edit webdav/secret.yaml with your password
kubectl apply -f webdav/secret.yaml
```

## Tuna Tunnel Setup

```bash
cp tuna/secret.yaml.example tuna/secret.yaml
# Edit tuna/secret.yaml with your tuna token
kubectl apply -f tuna/secret.yaml
```

## Repo Secrets

```bash
cp argocd/repo-secrets.yaml.example argocd/repo-secrets.yaml
# Edit with your GitHub token
kubectl apply -f argocd/repo-secrets.yaml
```
