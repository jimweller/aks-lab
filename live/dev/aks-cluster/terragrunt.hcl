# Include root configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Specify the Terraform module to use
terraform {
  source = "../../../modules/aks-cluster"
}

# Local configuration that reads from parent configs
locals {
  # Read configurations for DRY principle
  env_vars = read_terragrunt_config("../terragrunt.hcl")
}

# Define dependencies
dependency "networking" {
  config_path = "../networking"
  
  mock_outputs = {
    resource_group_name = "mock-rg"
    location           = "West US 2"
    aks_subnet_id      = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/mock-subnet"
  }
}

dependency "acr" {
  config_path = "../acr"
  
  mock_outputs = {
    acr_id = "/subscriptions/mock/resourceGroups/mock-rg/providers/Microsoft.ContainerRegistry/registries/mock-acr"
  }
}

# Input values for the AKS cluster module (only AKS-specific config)
inputs = {
  # Use shared naming conventions from environment level
  cluster_name        = local.env_vars.locals.cluster_name
  resource_group_name = dependency.networking.outputs.resource_group_name
  location           = dependency.networking.outputs.location
  subnet_id          = dependency.networking.outputs.aks_subnet_id
  acr_id             = dependency.acr.outputs.acr_id
  tags               = local.env_vars.locals.env_tags

  # AKS-specific configuration (unique to AKS component)
  dns_prefix         = "aks-${local.env_vars.locals.environment}-${local.env_vars.locals.root_vars.locals.deploy_token}"
  kubernetes_version = null  # Use latest stable version

  # Default node pool configuration
  default_node_pool = {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2s_v3"
    enable_auto_scaling = false
    min_count       = 1
    max_count       = 3
    max_pods        = 30
    os_disk_size_gb = 128
    os_disk_type    = "Managed"
    max_surge       = "10%"
  }

  # Network configuration
  network_policy  = "azure"
  dns_service_ip  = "10.2.0.10"
  service_cidr    = "10.2.0.0/24"
  outbound_type   = "loadBalancer"

  # Azure AD integration (disabled for basic lab)
  enable_azure_ad_rbac = false
  tenant_id           = null
  admin_group_object_ids = []
  azure_rbac_enabled  = false

  # Add-ons configuration
  enable_key_vault_secrets_provider = true
  secret_rotation_enabled           = true
  secret_rotation_interval          = "2m"
  
  enable_http_application_routing = false
  enable_azure_policy            = false
  enable_oms_agent              = false
  enable_application_gateway_ingress = false
  enable_open_service_mesh      = false

  # Workload Identity
  enable_workload_identity = true

  # Private cluster (disabled for basic lab)
  enable_private_cluster                 = false
  private_dns_zone_id                   = null
  private_cluster_public_fqdn_enabled   = false
  api_server_authorized_ip_ranges       = null

  # Security settings
  disable_local_accounts = false

  # Image cleaner
  enable_image_cleaner        = false
  image_cleaner_interval_hours = 168

  # Node resource group
  node_resource_group = null

  # Storage profile
  storage_profile = {
    blob_driver_enabled         = false
    disk_driver_enabled         = true
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }

  # Monitoring
  log_analytics_workspace_id      = null
  msi_auth_for_monitoring_enabled = true
}