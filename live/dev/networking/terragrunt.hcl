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
  source = "../../../modules/networking"
}

# Input values for the networking module
inputs = {
  resource_group_name = include.env.locals.resource_group_name
  location           = include.env.locals.region
  vnet_name          = include.env.locals.vnet_name
  tags               = include.env.locals.common_tags

  # Network configuration
  vnet_address_space                   = "10.0.0.0/16"
  aks_subnet_name                     = "aks-subnet"
  aks_subnet_address_prefix           = "10.0.1.0/24"
  app_gateway_subnet_name             = "app-gateway-subnet"
  app_gateway_subnet_address_prefix   = "10.0.2.0/24"
}