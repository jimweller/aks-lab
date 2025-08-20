# Echo Server Workload

This workload deploys a simple echo server to the Kubernetes cluster. The echo server is a useful utility for testing network connectivity, Ingress routing, and request headers.

## Deployment

The `deployment.yaml` file contains the following Kubernetes resources:

- **Deployment**: Deploys the echo server application using the `hashicorp/http-echo` container image
- **Service**: Exposes the echo server pods within the cluster using a `ClusterIP` service
- **Ingress**: (Optional) Provides external access to the echo server. You will need to configure an Ingress controller in your cluster for this to work

## Usage

To deploy the echo server, use the following command:

```bash
kubectl apply -f workloads/echo-server/deployment.yaml
```

Once deployed, you can test the echo server by port-forwarding to the service:

```bash
kubectl port-forward svc/echo-server-service 8080:80
```

Then, in a separate terminal, you can send requests to the echo server:

```bash
curl http://localhost:8080

