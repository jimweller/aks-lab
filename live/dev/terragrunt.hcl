# Include all settings from the root terragrunt.hcl file
include "root" {
  path = find_in_parent_folders()
}

# Include all settings from the root terragrunt.hcl file
include "root" {
  path = find_in_parent_folders()
}

# Generate deploy token unique to this environment - consistent across runs
generate "deploy_token" {
  path = "deploy_token.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
resource "random_string" "deploy_token" {
  length  = 4
  special = false
  upper   = false
}

output "deploy_token" {
  value = "z$${random_string.deploy_token.result}"
}
EOF
}

# Environment-specific variables
locals {
  environment = "dev"
  region      = "East US"
  
  # Deploy token: generated once, then consistent across all runs
  deploy_token = "z${random_string.deploy_token.result}"
  
  # Common tags for all resources in this environment
  common_tags = {
    project     = "aks-lab"
    environment = local.environment
    managed_by  = "terragrunt"
    owner       = "platform-team"
    deploy_token = local.deploy_token
  }

  # Naming conventions: RESOURCE-dev-key pattern
  resource_group_name = "rg-aks-lab-${local.environment}-${local.deploy_token}"
  cluster_name        = "aks-cluster-${local.environment}-${local.deploy_token}"
  acr_name            = "akslabregistry${local.environment}${local.deploy_token}"
  vnet_name           = "aks-vnet-${local.environment}-${local.deploy_token}"
}