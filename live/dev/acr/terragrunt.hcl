# Include root configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Specify the Terraform module to use
terraform {
  source = "../../../modules/acr"
}

# Local configuration that reads from parent configs
locals {
  # Read configurations for DRY principle
  env_vars = read_terragrunt_config("../terragrunt.hcl")
}

# Define dependencies
dependency "networking" {
  config_path = "../networking"
  
  mock_outputs = {
    resource_group_name = "mock-rg"
    location           = "West US 2"
  }
}

# Input values for the ACR module (only ACR-specific config)
inputs = {
  # Use shared naming conventions from environment level
  acr_name            = local.env_vars.locals.acr_name
  resource_group_name = dependency.networking.outputs.resource_group_name
  location           = dependency.networking.outputs.location
  tags               = local.env_vars.locals.env_tags

  # ACR-specific configuration (unique to ACR component)
  acr_sku        = "Basic"
  admin_enabled  = false

  # Security settings
  public_network_access_enabled = true

  # Private endpoint (disabled for basic lab)
  enable_private_endpoint = false
}