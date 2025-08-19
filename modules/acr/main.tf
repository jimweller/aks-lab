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

  # Network rule set for additional security
  dynamic "network_rule_set" {
    for_each = var.network_rule_set_enabled ? [1] : []
    content {
      default_action = var.network_rule_default_action

      dynamic "ip_rule" {
        for_each = var.allowed_ip_ranges
        content {
          action   = "Allow"
          ip_range = ip_rule.value
        }
      }

      dynamic "virtual_network" {
        for_each = var.allowed_subnet_ids
        content {
          action    = "Allow"
          subnet_id = virtual_network.value
        }
      }
    }
  }

  # Retention policy for untagged manifests
  dynamic "retention_policy" {
    for_each = var.retention_policy_enabled ? [1] : []
    content {
      days    = var.retention_policy_days
      enabled = true
    }
  }

  # Trust policy for content trust
  dynamic "trust_policy" {
    for_each = var.trust_policy_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # Quarantine policy for vulnerability scanning
  dynamic "quarantine_policy" {
    for_each = var.quarantine_policy_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  # Export policy
  dynamic "export_policy" {
    for_each = var.export_policy_enabled ? [1] : []
    content {
      enabled = true
    }
  }

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