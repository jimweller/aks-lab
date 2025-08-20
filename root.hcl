# Root Terragrunt configuration to define global variables and configurations

locals {
  # Fetch bootstrap outputs from local state file - FATAL if bootstrap not applied
  bootstrap_deploy_token = run_cmd("tofu", "output", "-state=bootstrap/terraform.tfstate", "-raw", "deploy_token")
  bootstrap_storage_account = run_cmd("tofu", "output", "-state=bootstrap/terraform.tfstate", "-raw", "name")
  bootstrap_project_name = run_cmd("tofu", "output", "-state=bootstrap/terraform.tfstate", "-raw", "project_name")
  bootstrap_location = run_cmd("tofu", "output", "-state=bootstrap/terraform.tfstate", "-raw", "location")
  
  # Use bootstrap outputs for consistency
  deploy_token = local.bootstrap_deploy_token
  project_name = local.bootstrap_project_name
  storage_account_name = local.bootstrap_storage_account
  azure_region = local.bootstrap_location
  
  # Common tags applied to all resources
  common_tags = {
    project      = "aks-lab"
    managed_by   = "terragrunt"
    deploy_token = local.deploy_token
    
    # MCG mandatory tags
    Application  = "aks-lab"
    BusinessUnit = "Technology"
    CostCenter   = "IT-Infrastructure"
    ServiceTeam  = "Platform-Engineering"
    Environment  = "Development"
    Product      = "AKS-Lab"
  }
}

# Configure Terragrunt to automatically store tfstate files in Azure Storage
remote_state {
  backend = "azurerm"
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  
  config = {
    # Backend storage is shared across environments - use bootstrap outputs
    resource_group_name  = "rg-${local.project_name}-tfstate"
    storage_account_name = local.storage_account_name
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
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "ec285aeb-6f1f-4a4b-8055-95a54af4f1b0"
}

provider "azuread" {}
EOF
}