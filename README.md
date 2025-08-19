# AKS Lab

A learning lab for Azure Kubernetes Service (AKS) using Terragrunt and Terraform modules.

## Overview

This lab provides a modular approach to deploying and experimenting with AKS clusters. It uses Terragrunt to orchestrate Terraform modules, making it easy to manage dependencies and environment-specific configurations.

## Architecture

- **Networking**: Azure CNI with dedicated subnets for AKS nodes and Application Gateway
- **Identity**: Managed Identity for cluster, Azure AD Workload Identity for pods  
- **Storage**: Azure Managed Disks for persistent volumes
- **Registry**: Azure Container Registry with cluster attachment
- **Ingress**: Application Gateway Ingress Controller (AGIC)
- **Secrets**: Azure Key Vault with Secrets Store CSI Driver
- **Certificates**: cert-manager with Let's Encrypt

## Structure

```
aks-lab/
├── terragrunt.hcl          # Root Terragrunt configuration
├── modules/                # Reusable Terraform modules
│   ├── networking/         # VNet, subnets, NSGs
│   ├── aks-cluster/        # AKS cluster with managed identity
│   └── acr/                # Azure Container Registry
└── live/                   # Environment-specific configurations
    └── dev/
        ├── terragrunt.hcl  # Environment variables
        ├── networking/     # Networking deployment
        ├── aks-cluster/    # AKS cluster deployment
        └── acr/            # ACR deployment
```

## Prerequisites

1. **Azure CLI**: Install and login to Azure
   ```bash
   az login
   az account set --subscription <subscription-id>
   ```

2. **Terraform**: Install Terraform >= 1.0
   ```bash
   # macOS
   brew install terraform
   
   # Or download from: https://www.terraform.io/downloads
   ```

3. **Terragrunt**: Install Terragrunt
   ```bash
   # macOS
   brew install terragrunt
   
   # Or download from: https://github.com/gruntwork-io/terragrunt/releases
   ```

4. **kubectl**: Install kubectl for cluster interaction
   ```bash
   # macOS
   brew install kubernetes-cli
   
   # Or download from: https://kubernetes.io/docs/tasks/tools/
   ```

## Quick Start

### 1. Configure Backend Storage

First, create a storage account for Terraform state:

```bash
# Create resource group for Terraform state
az group create --name rg-aks-lab-tfstate --location "East US"

# Create storage account
az storage account create \
  --name stakslabakstfstate \
  --resource-group rg-aks-lab-tfstate \
  --location "East US" \
  --sku Standard_LRS

# Create storage container
az storage container create \
  --name tfstate \
  --account-name stakslabakstfstate
```

### 2. Deploy Infrastructure

Deploy components in order due to dependencies:

```bash
# Deploy networking first
cd live/dev/networking
terragrunt plan
terragrunt apply

# Deploy ACR
cd ../acr
terragrunt plan  
terragrunt apply

# Deploy AKS cluster
cd ../aks-cluster
terragrunt plan
terragrunt apply
```

### 3. Connect to Cluster

```bash
# Get cluster credentials
az aks get-credentials --resource-group rg-dev-aks-lab --name dev-aks-cluster

# Verify connection
kubectl get nodes
```

## Usage

### Deploy All Components

```bash
# From the live/dev directory
cd live/dev
terragrunt run-all plan
terragrunt run-all apply
```

### Deploy Individual Components

```bash
# Deploy only networking
cd live/dev/networking
terragrunt apply

# Deploy only AKS cluster
cd live/dev/aks-cluster  
terragrunt apply
```

### Destroy Infrastructure

```bash
# Destroy all components (reverse order)
cd live/dev
terragrunt run-all destroy
```

## Modules

### Networking Module

Creates:
- Resource Group
- Virtual Network
- AKS subnet
- Application Gateway subnet  
- Network Security Groups

### AKS Cluster Module

Creates:
- User Assigned Managed Identity
- AKS cluster with Azure CNI
- RBAC role assignments

### ACR Module

Creates:
- Azure Container Registry
- Network rules and policies
- Private endpoint support

## Next Steps

After deploying the basic infrastructure:

1. **Install Metrics Server**: Deploy metrics-server for resource monitoring
2. **Configure Autoscaling**: Set up Cluster Autoscaler or Karpenter
3. **Deploy Workloads**: Test with sample applications
4. **Set up Ingress**: Configure AGIC for external access
5. **Add Secrets Management**: Integrate Azure Key Vault
6. **Configure Certificates**: Set up cert-manager with Let's Encrypt

## Troubleshooting

### Common Issues

1. **Terraform State Issues**: Ensure Azure storage account exists and you have proper permissions
2. **AKS Permissions**: Verify your Azure account has Contributor role on the subscription
3. **Subnet Issues**: Check that subnet CIDRs don't overlap and have sufficient IP space
4. **ACR Integration**: Ensure AKS managed identity has AcrPull role on the registry

### Cleanup

To completely clean up:

```bash
# Destroy all Terragrunt-managed resources
cd live/dev
terragrunt run-all destroy

# Remove the Terraform state storage (optional)
az group delete --name rg-aks-lab-tfstate --yes --no-wait