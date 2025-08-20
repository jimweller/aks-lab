# Stress Test Workload

This workload deploys a stress testing application that forces high CPU and memory usage to trigger autoscaling in the AKS cluster.

## Purpose

The stress test workload is designed to:

- Generate high CPU and memory load to test cluster autoscaling
- Validate Horizontal Pod Autoscaler (HPA) functionality
- Test cluster node scaling under load
- Demonstrate resource management and scaling policies

## Components

### Deployment

- **Image**: `colinianking/stress-ng:latest` - A comprehensive stress testing tool
- **Resources**: Requests and limits set to 1 CPU core and 1GB memory per pod
- **Stress Parameters**:
  - 1 CPU core stress test
  - 1 virtual memory stress test
  - 5-minute timeout per run

### HorizontalPodAutoscaler (HPA)

- **Min Replicas**: 1
- **Max Replicas**: 10
- **CPU Target**: Scale when average CPU > 50%
- **Memory Target**: Scale when average memory > 70%
- **Scale-up**: 1-minute stabilization window
- **Scale-down**: 5-minute stabilization window

## Prerequisites

For autoscaling to work properly:

1. **Metrics Server**: Must be installed in the cluster

   ```bash
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   ```

2. **Cluster Autoscaler**: Should be enabled on the AKS cluster for node-level scaling

## Usage

### Deploy the Stress Test

```bash
kubectl apply -f workloads/stress-test/deployment.yaml
```

### Monitor Autoscaling

```bash
# Watch HPA status
kubectl get hpa stress-test-hpa --watch

# Watch pod scaling
kubectl get pods -l app=stress-test --watch

# Watch node scaling (if cluster autoscaler is enabled)
kubectl get nodes --watch
```

### Manual Scaling Test

```bash
# Scale up deployment to force more load
kubectl scale deployment stress-test --replicas=5

# Monitor the effects
kubectl top pods
kubectl top nodes
```

### Check Resource Usage

```bash
# Check current resource usage
kubectl top pods -l app=stress-test
kubectl top nodes

# Check HPA status
kubectl describe hpa stress-test-hpa
```

## Cleanup

```bash
# Remove the stress test workload
kubectl delete -f workloads/stress-test/deployment.yaml
```

## Notes

- The stress test runs for 5 minutes per pod, then exits
- Pods will be restarted automatically due to the deployment spec
- Monitor cluster costs when running stress tests as they can trigger node scaling
- Use this workload to validate autoscaling configuration and policies
