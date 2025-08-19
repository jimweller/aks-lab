# Include all settings from the root terragrunt.hcl file
include "root" {
  path = find_in_parent_folders()
}

# Include environment-specific settings
include "env" {
  path   = find_in_parent_folders("terragrunt.hcl")
  expose = true
}

# Specify the Terraform module to use
terraform {
  source = "../../../modules/acr"
}

# Define dependencies
dependency "networking" {
  config_path = "../networking"
  
  mock_outputs = {
    resource_group_name = "mock-rg"
    location           = "East US"
  }
}

# Input values for the ACR module
inputs = {
  acr_name            = include.env.locals.acr_name
  resource_group_name = dependency.networking.outputs.resource_group_name
  location           = dependency.networking.outputs.location
  tags               = include.env.locals.common_tags

  # ACR configuration
  acr_sku        = "Basic"
  admin_enabled  = false

  # Security settings
  public_network_access_enabled = true
  network_rule_set_enabled      = false
  retention_policy_enabled      = false
  trust_policy_enabled          = false
  quarantine_policy_enabled     = false
  export_policy_enabled         = true

  # Private endpoint (disabled for basic lab)
  enable_private_endpoint = false
}