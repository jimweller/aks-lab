# Include root configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Specify the Terraform module to use
terraform {
  source = "../../../modules/networking"
}

# Local configuration that reads from parent configs
locals {
  # Read configurations for DRY principle
  root_vars = read_terragrunt_config(find_in_parent_folders("root.hcl"))
  env_vars  = read_terragrunt_config("../terragrunt.hcl")
}

# Input values for the networking module (only networking-specific config)
inputs = {
  # Use shared naming conventions from environment level
  resource_group_name = local.env_vars.locals.resource_group_name
  location           = local.root_vars.locals.azure_region
  vnet_name          = local.env_vars.locals.vnet_name
  tags               = local.env_vars.locals.env_tags

  # Network-specific configuration (unique to networking component)
  vnet_address_space                   = "10.0.0.0/16"
  aks_subnet_name                     = "aks-subnet"
  aks_subnet_address_prefix           = "10.0.1.0/24"
  app_gateway_subnet_name             = "app-gateway-subnet"
  app_gateway_subnet_address_prefix   = "10.0.2.0/24"
}