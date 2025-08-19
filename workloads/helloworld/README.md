# Hello World Workload

A simple nginx deployment to verify basic AKS functionality.

## Components

- **Deployment**: nginx container with resource limits
- **Service**: ClusterIP service for internal access  
- **Ingress**: Application Gateway ingress for external access

## Deploy

```bash
kubectl apply -f deployment.yaml
```

## Verify

```bash
# Check pods
kubectl get pods -l app=helloworld

# Check service
kubectl get svc helloworld-service

# Check ingress
kubectl get ingress helloworld-ingress

# Test locally (port-forward)
kubectl port-forward svc/helloworld-service 8080:80
curl http://localhost:8080
```

## Clean up

```bash
kubectl delete -f deployment.yaml