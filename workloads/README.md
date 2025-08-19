# Workloads

Sample Kubernetes workloads for testing AKS cluster functionality.

## Available Workloads

### Hello World (`helloworld/`)

Basic nginx deployment to verify:
- Pod scheduling and networking
- Service creation and discovery
- Ingress configuration with AGIC

### Secret Demo (`secret-demo/`)

Demonstrates Azure integrations:
- Azure AD Workload Identity
- Azure Key Vault integration via Secrets Store CSI Driver
- Secure secret mounting without storing credentials in cluster

## Prerequisites

Before deploying workloads:

1. **AKS cluster deployed** with Key Vault Secrets Provider addon enabled
2. **Application Gateway** configured for ingress (if using ingress resources)
3. **Azure Key Vault** created with appropriate secrets (for secret-demo)
4. **Workload Identity** configured (for secret-demo)

## Quick Deploy

```bash
# Deploy simple hello world
kubectl apply -f helloworld/deployment.yaml

# Verify deployment
kubectl get pods,svc,ingress -l app=helloworld
```

## Advanced Features

The secret-demo workload showcases Azure-specific integrations that differentiate AKS from other Kubernetes distributions. Review the individual README files for detailed setup instructions.