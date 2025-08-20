# Workloads

Sample Kubernetes workloads for testing AKS cluster functionality.

## Available Workloads

### Hello World (`helloworld/`)

Basic nginx deployment to verify:

- Pod scheduling and networking
- Service creation and discovery
- Ingress configuration with AGIC

### Echo Server (`echo-server/`)

Simple HTTP echo server for testing:

- Network connectivity and routing
- Ingress controller functionality
- Request/response debugging
- Uses `hashicorp/http-echo` container

### Secret Demo (`secret-demo/`)

Demonstrates Azure integrations:

- Azure AD Workload Identity
- Azure Key Vault integration via Secrets Store CSI Driver
- Secure secret mounting without storing credentials in cluster

### Stress Test (`stress-test/`)

Load testing workload to trigger autoscaling:

- Forces high CPU and memory usage
- Tests Horizontal Pod Autoscaler (HPA)
- Validates cluster node autoscaling
- Uses `colinianking/stress-ng` container with HPA configuration

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

# Deploy echo server for testing
kubectl apply -f echo-server/deployment.yaml

# Deploy stress test (will trigger autoscaling)
kubectl apply -f stress-test/deployment.yaml

# Verify deployments
kubectl get pods,svc,ingress
kubectl get hpa  # Check horizontal pod autoscaler status
```

## Advanced Features

The secret-demo workload showcases Azure-specific integrations that differentiate AKS from other Kubernetes distributions. Review the individual README files for detailed setup instructions.
