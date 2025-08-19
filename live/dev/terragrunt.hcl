# Include all settings from the root terragrunt.hcl file
include "root" {
  path = find_in_parent_folders()
}

# Environment-specific variables
locals {
  environment = "dev"
  region      = "East US"
  
  # Common tags for all resources in this environment
  common_tags = {
    project     = "aks-lab"
    environment = local.environment
    managed_by  = "terragrunt"
    owner       = "platform-team"
  }

  # Naming conventions
  resource_group_name = "rg-${local.environment}-aks-lab"
  cluster_name        = "${local.environment}-aks-cluster"
  acr_name            = "${local.environment}akslabregistry"
  vnet_name           = "${local.environment}-aks-vnet"
}