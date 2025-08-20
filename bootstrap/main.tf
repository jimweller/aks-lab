terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "ec285aeb-6f1f-4a4b-8055-95a54af4f1b0"
}

# Generate a random token for unique resource naming
resource "random_string" "token" {
  length  = 4
  special = false
  upper   = false
}

# Local values for consistent naming and tagging
locals {
  deploy_token = var.deploy_token == null ? "z${random_string.token.result}" : var.deploy_token
  common_tags = merge(var.tags, {
    test-scenario = "manual"
  })
}

# Create resource group for Terraform state
resource "azurerm_resource_group" "tfstate" {
  name     = var.tfstate_resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Create storage account for Terraform state
resource "azurerm_storage_account" "tfstate" {
  name                     = "${replace(var.project_name, "-", "")}tfstate${local.deploy_token}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Security settings
  min_tls_version                = "TLS1_2"
  allow_nested_items_to_be_public = false
  
  # Enable versioning for state file protection
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }

  tags = local.common_tags
}

# Create container for Terraform state files
resource "azurerm_storage_container" "tfstate" {
  name                 = var.tfstate_container_name
  storage_account_id   = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}