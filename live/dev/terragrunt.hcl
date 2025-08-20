# Include root configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Environment-specific locals
locals {
  environment = "dev"
  
  # Read root configuration for shared values
  root_vars = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  
  # Naming conventions using root locals
  resource_group_name = "rg-aks-lab-${local.environment}-${local.root_vars.locals.deploy_token}"
  cluster_name        = "aks-cluster-${local.environment}-${local.root_vars.locals.deploy_token}"
  acr_name            = "akslabregistry${local.environment}${local.root_vars.locals.deploy_token}"
  vnet_name           = "aks-vnet-${local.environment}-${local.root_vars.locals.deploy_token}"
  
  # Environment-specific tags (merged with root tags)
  env_tags = merge(local.root_vars.locals.common_tags, {
    environment = local.environment
  })
}