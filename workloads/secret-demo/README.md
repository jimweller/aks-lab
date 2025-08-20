# Secret Demo Workload

Demonstrates Azure Key Vault integration with AKS using the Secrets Store CSI Driver and Azure AD Workload Identity.

## Prerequisites

1. Azure Key Vault created and configured
2. Workload Identity configured for the cluster
3. Secrets Store CSI Driver addon enabled
4. Service account configured with workload identity annotations

## Setup

Before deploying, update the placeholders in `deployment.yaml`:

- `CLIENT_ID_PLACEHOLDER`: Client ID of the managed identity
- `KEY_VAULT_NAME_PLACEHOLDER`: Name of your Azure Key Vault
- `TENANT_ID_PLACEHOLDER`: Your Azure AD tenant ID

## Components

- **ServiceAccount**: Configured for Azure AD Workload Identity
- **SecretProviderClass**: Defines which secrets to mount from Key Vault
- **Deployment**: nginx container with secrets mounted as volume
- **Service**: ClusterIP service for access

## Deploy

```bash
# Update placeholders in deployment.yaml first, then:
kubectl apply -f deployment.yaml
```

## Verify

```bash
# Check pods
kubectl get pods -l app=secret-demo

# Check secret provider class
kubectl get secretproviderclass azure-keyvault-secrets

# Exec into pod to verify secret mount
kubectl exec -it deployment/secret-demo -- ls -la /mnt/secrets

# View secret content (if accessible)
kubectl exec -it deployment/secret-demo -- cat /mnt/secrets/app-secret
```

## Clean up

```bash
kubectl delete -f deployment.yaml

