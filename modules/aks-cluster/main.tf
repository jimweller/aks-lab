# Create managed identity for AKS cluster
resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.cluster_name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Create AKS cluster
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  # Default node pool
  default_node_pool {
    name           = var.default_node_pool.name
    node_count     = var.default_node_pool.node_count
    vm_size        = var.default_node_pool.vm_size
    vnet_subnet_id = var.subnet_id
    max_pods       = var.default_node_pool.max_pods
    os_disk_size_gb = var.default_node_pool.os_disk_size_gb
    os_disk_type   = var.default_node_pool.os_disk_type
    type           = "VirtualMachineScaleSets"
    
    upgrade_settings {
      max_surge = var.default_node_pool.max_surge
    }
  }

  # Managed identity
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # Network profile for Azure CNI
  network_profile {
    network_plugin    = "azure"
    network_policy    = var.network_policy
    dns_service_ip    = var.dns_service_ip
    service_cidr      = var.service_cidr
    load_balancer_sku = "standard"
    outbound_type     = var.outbound_type
  }

  # Azure AD integration
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_azure_ad_rbac ? [1] : []
    content {
      tenant_id              = var.tenant_id
      admin_group_object_ids = var.admin_group_object_ids
      azure_rbac_enabled     = var.azure_rbac_enabled
    }
  }

  # Key Vault Secrets Provider addon
  dynamic "key_vault_secrets_provider" {
    for_each = var.enable_key_vault_secrets_provider ? [1] : []
    content {
      secret_rotation_enabled  = var.secret_rotation_enabled
      secret_rotation_interval = var.secret_rotation_interval
    }
  }

  # HTTP application routing (not recommended for production)
  http_application_routing_enabled = var.enable_http_application_routing

  # OMS agent addon (Azure Monitor)
  dynamic "oms_agent" {
    for_each = var.enable_oms_agent ? [1] : []
    content {
      log_analytics_workspace_id      = var.log_analytics_workspace_id
      msi_auth_for_monitoring_enabled = var.msi_auth_for_monitoring_enabled
    }
  }

  # Ingress Application Gateway addon
  dynamic "ingress_application_gateway" {
    for_each = var.enable_application_gateway_ingress ? [1] : []
    content {
      gateway_id   = var.application_gateway_id
      subnet_cidr  = var.application_gateway_subnet_cidr
      subnet_id    = var.application_gateway_subnet_id
    }
  }

  # Workload Identity (OIDC Issuer)
  oidc_issuer_enabled       = var.enable_workload_identity
  workload_identity_enabled = var.enable_workload_identity

  # Private cluster configuration
  private_cluster_enabled             = var.enable_private_cluster
  private_dns_zone_id                 = var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled

  # API server access profile
  dynamic "api_server_access_profile" {
    for_each = var.api_server_authorized_ip_ranges != null ? [1] : []
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  # Local account disabled
  local_account_disabled = var.disable_local_accounts

  # Image cleaner
  image_cleaner_enabled        = var.enable_image_cleaner
  image_cleaner_interval_hours = var.image_cleaner_interval_hours

  # Node resource group
  node_resource_group = var.node_resource_group

  # Storage profile
  storage_profile {
    blob_driver_enabled         = var.storage_profile.blob_driver_enabled
    disk_driver_enabled         = var.storage_profile.disk_driver_enabled
    file_driver_enabled         = var.storage_profile.file_driver_enabled
    snapshot_controller_enabled = var.storage_profile.snapshot_controller_enabled
  }

  depends_on = [
    azurerm_user_assigned_identity.aks
  ]
}

# Assign Network Contributor role to AKS managed identity on the subnet
resource "azurerm_role_assignment" "aks_network_contributor" {
  scope                = var.subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Assign AcrPull role to AKS managed identity on the ACR (if provided)
resource "azurerm_role_assignment" "aks_acr_pull" {
  count                = var.acr_id != null ? 1 : 0
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}