# Root Terragrunt configuration to define global variables and configurations

locals {
  # Common tags applied to all resources
  common_tags = {
    project     = "aks-lab"
    environment = "dev"
    managed_by  = "terragrunt"
  }

  # Azure region for deployment
  azure_region = "West US 2"
  
  # Resource naming convention
  project_name = "jim-aks-lab"
}

# Configure Terragrunt to automatically store tfstate files in Azure Storage
remote_state {
  backend = "azurerm"
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  
  config = {
    # Update these values after running bootstrap
    resource_group_name  = "rg-${local.project_name}-tfstate"
    storage_account_name = "REPLACE_WITH_BOOTSTRAP_OUTPUT"
    container_name       = "tfstate"
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