# Bootstrap Infrastructure

This directory contains Terraform configuration to provision the Azure Storage Account and related resources needed for storing Terraform state files.

## Purpose

The bootstrap infrastructure creates:
- Resource Group for Terraform state storage
- Storage Account with versioning and security features enabled
- Storage Container for state files
- Shared configuration values (deploy_token, project_name, etc.) for use by main Terragrunt configuration

## Prerequisites

- Azure CLI installed and authenticated (`az login`)
- Terraform installed (>= 1.0)
- Appropriate Azure permissions to create Resource Groups and Storage Accounts

## Usage

### 1. Initialize Terraform

```bash
cd bootstrap
terraform init
```

### 2. Plan the deployment

```bash
terraform plan
```

### 3. Apply the configuration

```bash
terraform apply
```

### 4. Note the outputs

After successful deployment, note the outputs which will be needed for configuring the main Terragrunt backend:

```bash
terraform output
```

## Important Notes

- The storage account name includes a random suffix to ensure uniqueness
- Blob versioning is enabled to protect against accidental state file corruption
- The storage account uses private access only for security
- State files are retained for 30 days after deletion

## Customization

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
project_name = "my-aks-lab"
location = "East US"
tfstate_resource_group_name = "rg-my-aks-lab-tfstate"