variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "acr_sku" {
  description = "SKU for Azure Container Registry"
  type        = string
  default     = "Basic"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "ACR SKU must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Enable admin user for ACR"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "public_network_access_enabled" {
  description = "Enable public network access to ACR"
  type        = bool
  default     = true
}

# Note: network_rule_set, retention_policy, trust_policy, quarantine_policy,
# and export_policy variables have been removed as these features are either
# no longer supported or incompatible with azurerm provider v4.0

variable "identity_type" {
  description = "Type of managed identity"
  type        = string
  default     = null
  validation {
    condition = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  description = "List of user assigned identity IDs"
  type        = list(string)
  default     = null
}

variable "encryption_enabled" {
  description = "Enable encryption using customer-managed keys"
  type        = bool
  default     = false
}

variable "key_vault_key_id" {
  description = "Key Vault key ID for encryption"
  type        = string
  default     = null
}

variable "encryption_identity_client_id" {
  description = "Client ID of the managed identity for encryption"
  type        = string
  default     = null
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for ACR"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs for private endpoint"
  type        = list(string)
  default     = null
}