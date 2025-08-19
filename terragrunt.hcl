# Root Terragrunt configuration to define global variables and configurations

# Reference bootstrap outputs for shared configuration
dependency "bootstrap" {
  config_path = "./bootstrap"
  
  # Skip outputs during bootstrap phase
  skip_outputs = true
  
  mock_outputs = {
    deploy_token = "zmock"
    project_name = "jim-aks-lab"
    location     = "West US 2"
    backend_config = {
      resource_group_name  = "rg-jim-aks-lab-tfstate"
      storage_account_name = "jimakslabzfstatemock"
      container_name       = "tfstate"
    }
    shared_config = {
      deploy_token = "zmock"
      project_name = "jim-aks-lab"
      location     = "West US 2"
      common_tags = {
        project       = "aks-lab"
        managed_by    = "terraform"
        test-scenario = "manual"
      }
    }
  }
}

locals {
  # Get shared configuration from bootstrap
  bootstrap_config = try(dependency.bootstrap.outputs.shared_config, dependency.bootstrap.mock_outputs.shared_config)
  backend_config   = try(dependency.bootstrap.outputs.backend_config, dependency.bootstrap.mock_outputs.backend_config)
  
  # Common tags applied to all resources
  common_tags = merge(local.bootstrap_config.common_tags, {
    environment = "dev"
    managed_by  = "terragrunt"
  })

  # Azure region for deployment
  azure_region = local.bootstrap_config.location
  
  # Resource naming convention with shared deploy_token
  project_name = local.bootstrap_config.project_name
  deploy_token = local.bootstrap_config.deploy_token
}

# Configure Terragrunt to automatically store tfstate files in Azure Storage
remote_state {
  backend = "azurerm"
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  
  config = {
    # Use backend configuration from bootstrap
    resource_group_name  = local.backend_config.resource_group_name
    storage_account_name = local.backend_config.storage_account_name
    container_name       = local.backend_config.container_name
    key                  = "${path_relative_to_include()}/terraform.tfstate"
  }
}

# Generate provider configuration
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}
EOF
}