# Create Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = var.admin_enabled
  tags                = var.tags

  # Enable public network access
  public_network_access_enabled = var.public_network_access_enabled

  # Note: Network rule set functionality simplified for v4.0 compatibility
  # Complex network rules have been removed to ensure compatibility

  # Identity for managed identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Encryption configuration
  dynamic "encryption" {
    for_each = var.encryption_enabled ? [1] : []
    content {
      key_vault_key_id   = var.key_vault_key_id
      identity_client_id = var.encryption_identity_client_id
    }
  }
}

# Create a private endpoint if required
resource "azurerm_private_endpoint" "acr" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.acr_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.acr_name}-psc"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_ids != null ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }
}