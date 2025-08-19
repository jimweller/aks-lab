output "storage_account_name" {
  description = "Name of the storage account for Terraform state"
  value       = azurerm_storage_account.tfstate.name
}

output "storage_account_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.tfstate.primary_access_key
  sensitive   = true
}

output "container_name" {
  description = "Name of the storage container for Terraform state files"
  value       = azurerm_storage_container.tfstate.name
}

output "resource_group_name" {
  description = "Name of the resource group containing the storage account"
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.tfstate.id
}

output "deploy_token" {
  description = "The deployment token used for unique resource naming"
  value       = local.deploy_token
}

output "project_name" {
  description = "The project name used for resource naming"
  value       = var.project_name
}

output "location" {
  description = "The Azure region where resources are deployed"
  value       = var.location
}

output "backend_config" {
  description = "Backend configuration for Terragrunt"
  value = {
    resource_group_name  = azurerm_resource_group.tfstate.name
    storage_account_name = azurerm_storage_account.tfstate.name
    container_name       = azurerm_storage_container.tfstate.name
  }
}

output "shared_config" {
  description = "Shared configuration values for use in main Terragrunt configuration"
  value = {
    deploy_token = local.deploy_token
    project_name = var.project_name
    location     = var.location
    common_tags  = local.common_tags
  }
}