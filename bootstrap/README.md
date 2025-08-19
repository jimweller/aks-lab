# Bootstrap Infrastructure

This directory contains Terraform configuration to provision the Azure Storage Account and related resources needed for storing Terraform state files.

## Purpose

The bootstrap infrastructure creates:
- Resource Group for Terraform state storage
- Storage Account with versioning and security features enabled
- Storage Container for state files
- Deploy token for unique resource naming

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

### 5. Backup Bootstrap State (Recommended)

After successful deployment, backup the bootstrap state to the storage account for team access and redundancy:

```bash
# Get the storage account name from terraform output
STORAGE_ACCOUNT_NAME=$(terraform output -raw storage_account_name)
RESOURCE_GROUP_NAME=$(terraform output -raw resource_group_name)

# Upload bootstrap state to the storage account
az storage blob upload \
  --account-name $STORAGE_ACCOUNT_NAME \
  --container-name tfstate \
  --name bootstrap/terraform.tfstate \
  --file terraform.tfstate

# Verify the upload
az storage blob list \
  --account-name $STORAGE_ACCOUNT_NAME \
  --container-name tfstate \
  --prefix bootstrap/ \
  --output table
```

### 6. Restore Bootstrap State (If Needed)

To restore the bootstrap state from the storage account:

```bash
# Download the bootstrap state from storage account
STORAGE_ACCOUNT_NAME="<your-storage-account-name>"  # From terraform output or team member

az storage blob download \
  --account-name $STORAGE_ACCOUNT_NAME \
  --container-name tfstate \
  --name bootstrap/terraform.tfstate \
  --file terraform.tfstate

# Verify the restore worked
terraform show
```

## Bootstrap State Storage

**Important**: The bootstrap Terraform state is stored **locally** in a `terraform.tfstate` file. This is a common pattern for bootstrap configurations because:

- The bootstrap creates the remote state storage that other configurations will use
- It's a "chicken and egg" problem - you need storage to store state, but need state to create storage
- The bootstrap state is small and changes infrequently

### State Management Options:

1. **Local State (Current)** - Simple, suitable for single-person projects
2. **Version Control** - Commit the `terraform.tfstate` to git (acceptable for small teams)
3. **Separate Storage** - Use a pre-existing storage account for bootstrap state
4. **Team Coordination** - Designate one person to manage bootstrap, share outputs

### Recommended Approach:
For teams, consider committing the bootstrap `terraform.tfstate` to version control since:
- It's small and changes rarely
- It contains non-sensitive infrastructure metadata
- It ensures team members can access the same bootstrap state

## Important Notes

- The storage account name includes the deploy_token to ensure uniqueness
- Blob versioning is enabled to protect against accidental state file corruption
- The storage account uses private access only for security
- State files are retained for 30 days after deletion
- All main infrastructure will use the same deploy_token for consistent naming

## Deploy Token Pattern

The bootstrap uses a `deploy_token` pattern for unique resource naming:

- If `deploy_token` is not provided, a random token is generated with format `z{4-char-random}`
- If `deploy_token` is provided, it uses that exact value
- This token is shared with the main Terragrunt configuration for consistent naming

## Shared Configuration

The bootstrap outputs key values needed for the backend configuration:

- `storage_account_name`: Name of the created storage account
- `deploy_token`: Unique deployment identifier
- `project_name`: Project name used for naming
- `location`: Azure region
- `backend_config`: Complete backend configuration object

## Customization

You can customize the deployment by creating a `terraform.tfvars` file:

```hcl
project_name = "my-aks-lab"
location = "East US"
tfstate_resource_group_name = "rg-my-aks-lab-tfstate"