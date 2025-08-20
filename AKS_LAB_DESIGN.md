# AKS Lab Design Document

## 1. Objective

Create a baseline Azure Kubernetes Service (AKS) cluster for experimental and educational purposes, using a modular and maintainable Infrastructure as Code (IaC) approach with Terragrunt and Terraform.

## 2. High-Level Architecture

The lab will consist of a single AKS cluster with the following key integrations:

- **Networking:** Azure CNI
- **Identity:** Managed Identity for the cluster, Azure AD Workload Identity for pods
- **Storage:** Azure Managed Disks
- **Container Registry:** Azure Container Registry (ACR)
- **Ingress:** Application Gateway Ingress Controller (AGIC)
- **Secrets:** Azure Key Vault with Secrets Store CSI Driver
- **Certificates:** cert-manager with Let's Encrypt

## 3. IaC Structure with Terragrunt

We will use Terragrunt to orchestrate Terraform and maintain a clean, modular structure.

```text
aks-lab/
├── terragrunt.hcl      # Root Terragrunt configuration
├── modules/
│   ├── networking/     # Terraform module for VNet, subnets, etc.
│   ├── aks-cluster/    # Terraform module for the AKS cluster
│   └── acr/            # Terraform module for Azure Container Registry
└── live/
    └── dev/
        ├── terragrunt.hcl  # Environment-specific variables
        ├── networking/
        │   └── terragrunt.hcl
        ├── aks-cluster/
        │   └── terragrunt.hcl
        └── acr/
            └── terragrunt.hcl
```

## 4. Implementation Phases

1. **Phase 1: Foundational Modules**
   - Create Terraform modules for `networking`, `aks-cluster`, and `acr`
   - Use Terragrunt to deploy the foundational infrastructure

2. **Phase 2: Kubernetes Configuration**
   - Configure the Kubernetes provider to connect to the new cluster
   - Install the Metrics Server

3. **Phase 3: Autoscaling**
   - Configure the Cluster Autoscaler
   - (Optional) Implement Karpenter in NAP mode

4. **Phase 4: Application Ecosystem**
   - Deploy sample workloads
   - Configure AGIC for ingress
   - Set up cert-manager for TLS certificates
   - Integrate Azure Key Vault for secrets management

## 5. Key Technologies

- Terragrunt
- Terraform
- Kubernetes
- Azure AKS
- Azure CNI
- Azure Managed Identity
- Azure AD Workload Identity
- Azure Managed Disks
- Azure Container Registry
- Azure Application Gateway
- Azure Key Vault
- cert-manager
- Let's Encrypt
