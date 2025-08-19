# Include all settings from the root terragrunt.hcl file
include "root" {
  path = find_in_parent_folders()
  expose = true
}

# Environment-specific variables
locals {
  environment = "dev"
  region      = include.root.locals.azure_region
  
  # Common tags for all resources in this environment
  common_tags = merge(include.root.locals.common_tags, {
    environment = local.environment
    owner       = "platform-team"
  })

  # Naming conventions using shared project name and deploy token
  project_name        = include.root.locals.project_name
  deploy_token        = include.root.locals.deploy_token
  resource_group_name = "rg-${local.environment}-${local.project_name}-${local.deploy_token}"
  cluster_name        = "${local.environment}-aks-cluster-${local.deploy_token}"
  acr_name            = "${local.environment}${replace(local.project_name, "-", "")}acr${local.deploy_token}"
  vnet_name           = "${local.environment}-${local.project_name}-vnet-${local.deploy_token}"
}