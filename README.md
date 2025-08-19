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
├── bootstrap/              # Bootstrap infrastructure for Terraform state
│   ├── main.tf            # Storage account for Terraform state
│   ├── variables.tf       # Bootstrap configuration variables
│   ├── outputs.tf         # Bootstrap outputs
│   └── README.md          # Bootstrap usage instructions
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

### 1. Bootstrap Backend Infrastructure

First, deploy the Terraform state storage infrastructure using the bootstrap configuration:

```bash
# Navigate to bootstrap directory
cd bootstrap

# Initialize Terraform
terraform init

# Review the planned changes
terraform plan

# Deploy the storage infrastructure
terraform apply

# Note the storage account name and other outputs
terraform output

# Backup bootstrap state to storage account (recommended for teams)
STORAGE_ACCOUNT_NAME=$(terraform output -raw storage_account_name)
az storage blob upload \
  --account-name $STORAGE_ACCOUNT_NAME \
  --container-name tfstate \
  --name bootstrap/terraform.tfstate \
  --file terraform.tfstate
```

The bootstrap process creates:
- Resource Group for Terraform state storage
- Storage Account with versioning and security features
- Storage Container for state files

**Important Notes:**
1. The bootstrap Terraform state is stored locally in `bootstrap/terraform.tfstate`
2. A backup copy is stored in the storage account at `bootstrap/terraform.tfstate` for team access
3. You need to update the main `terragrunt.hcl` with the storage account name from bootstrap output

### 2. Update Backend Configuration

After bootstrap completes, update the storage account name in the root `terragrunt.hcl`:

```bash
# Get the storage account name from bootstrap output
cd bootstrap
STORAGE_ACCOUNT_NAME=$(terraform output -raw storage_account_name)
echo "Update terragrunt.hcl with: $STORAGE_ACCOUNT_NAME"

# Go back to root and update terragrunt.hcl
cd ..
# Replace REPLACE_WITH_BOOTSTRAP_OUTPUT with the actual storage account name
sed -i "s/REPLACE_WITH_BOOTSTRAP_OUTPUT/$STORAGE_ACCOUNT_NAME/g" terragrunt.hcl
```

### 3. Deploy Infrastructure

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

### 4. Connect to Cluster

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

# Destroy the bootstrap infrastructure (optional)
cd ../../bootstrap
terraform destroy

# Note: The bootstrap terraform.tfstate file will remain locally
# Remove manually if desired, or commit to version control for team use
```

### Bootstrap State Management

The bootstrap state (`bootstrap/terraform.tfstate`) contains metadata about the storage account and shared configuration. Consider:

- **Keep it**: For redeploying the same infrastructure with consistent naming
- **Commit it**: For team environments where multiple people need access
- **Delete it**: Only if you're completely done with the project and resources are destroyed