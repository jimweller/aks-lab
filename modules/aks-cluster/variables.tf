variable "cluster_name" {
  description = "Name of the AKS cluster"
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

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Version of Kubernetes to use for the AKS cluster"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "ID of the subnet where AKS nodes will be deployed"
  type        = string
}

variable "default_node_pool" {
  description = "Configuration for the default node pool"
  type = object({
    name                = string
    node_count          = number
    vm_size             = string
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    max_pods            = number
    os_disk_size_gb     = number
    os_disk_type        = string
    max_surge           = string
  })
  default = {
    name                = "default"
    node_count          = 2
    vm_size             = "Standard_D2s_v3"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 3
    max_pods            = 30
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    max_surge           = "10%"
  }
}

variable "network_policy" {
  description = "Network policy to use (azure or calico)"
  type        = string
  default     = "azure"
  validation {
    condition     = contains(["azure", "calico"], var.network_policy)
    error_message = "Network policy must be azure or calico."
  }
}

variable "dns_service_ip" {
  description = "IP address for the DNS service"
  type        = string
  default     = "10.2.0.10"
}

variable "service_cidr" {
  description = "CIDR block for Kubernetes services"
  type        = string
  default     = "10.2.0.0/24"
}

variable "outbound_type" {
  description = "Outbound type for the cluster"
  type        = string
  default     = "loadBalancer"
  validation {
    condition     = contains(["loadBalancer", "userDefinedRouting"], var.outbound_type)
    error_message = "Outbound type must be loadBalancer or userDefinedRouting."
  }
}

variable "enable_azure_ad_rbac" {
  description = "Enable Azure AD RBAC integration"
  type        = bool
  default     = true
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
  default     = null
}

variable "admin_group_object_ids" {
  description = "Object IDs of Azure AD groups that should have admin access"
  type        = list(string)
  default     = []
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC for Kubernetes authorization"
  type        = bool
  default     = true
}

variable "auto_scaler_profile" {
  description = "Auto scaler profile configuration"
  type = object({
    balance_similar_node_groups       = bool
    expander                         = string
    max_graceful_termination_sec     = string
    max_node_provisioning_time       = string
    max_unready_nodes               = number
    max_unready_percentage          = number
    new_pod_scale_up_delay          = string
    scale_down_delay_after_add      = string
    scale_down_delay_after_delete   = string
    scale_down_delay_after_failure  = string
    scan_interval                   = string
    scale_down_unneeded             = string
    scale_down_unready              = string
    scale_down_utilization_threshold = number
    empty_bulk_delete_max           = number
    skip_nodes_with_local_storage   = bool
    skip_nodes_with_system_pods     = bool
  })
  default = {
    balance_similar_node_groups       = false
    expander                         = "random"
    max_graceful_termination_sec     = "600"
    max_node_provisioning_time       = "15m"
    max_unready_nodes               = 3
    max_unready_percentage          = 45
    new_pod_scale_up_delay          = "10s"
    scale_down_delay_after_add      = "10m"
    scale_down_delay_after_delete   = "10s"
    scale_down_delay_after_failure  = "3m"
    scan_interval                   = "10s"
    scale_down_unneeded             = "10m"
    scale_down_unready              = "20m"
    scale_down_utilization_threshold = 0.5
    empty_bulk_delete_max           = 10
    skip_nodes_with_local_storage   = true
    skip_nodes_with_system_pods     = true
  }
}

variable "enable_key_vault_secrets_provider" {
  description = "Enable Key Vault Secrets Provider addon"
  type        = bool
  default     = true
}

variable "secret_rotation_enabled" {
  description = "Enable automatic secret rotation"
  type        = bool
  default     = true
}

variable "secret_rotation_interval" {
  description = "Secret rotation interval"
  type        = string
  default     = "2m"
}

variable "enable_http_application_routing" {
  description = "Enable HTTP application routing (not recommended for production)"
  type        = bool
  default     = false
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy addon"
  type        = bool
  default     = false
}

variable "enable_oms_agent" {
  description = "Enable OMS agent (Azure Monitor)"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for monitoring"
  type        = string
  default     = null
}

variable "msi_auth_for_monitoring_enabled" {
  description = "Enable MSI authentication for monitoring"
  type        = bool
  default     = true
}

variable "enable_application_gateway_ingress" {
  description = "Enable Application Gateway Ingress Controller"
  type        = bool
  default     = false
}

variable "application_gateway_id" {
  description = "ID of existing Application Gateway"
  type        = string
  default     = null
}

variable "application_gateway_subnet_cidr" {
  description = "CIDR for Application Gateway subnet"
  type        = string
  default     = null
}

variable "application_gateway_subnet_id" {
  description = "ID of Application Gateway subnet"
  type        = string
  default     = null
}

variable "enable_open_service_mesh" {
  description = "Enable Open Service Mesh addon"
  type        = bool
  default     = false
}

variable "enable_workload_identity" {
  description = "Enable Workload Identity (OIDC Issuer)"
  type        = bool
  default     = true
}

variable "enable_private_cluster" {
  description = "Enable private cluster"
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for private cluster"
  type        = string
  default     = null
}

variable "private_cluster_public_fqdn_enabled" {
  description = "Enable public FQDN for private cluster"
  type        = bool
  default     = false
}

variable "api_server_authorized_ip_ranges" {
  description = "Authorized IP ranges for API server access"
  type        = list(string)
  default     = null
}

variable "disable_local_accounts" {
  description = "Disable local accounts"
  type        = bool
  default     = true
}

variable "enable_image_cleaner" {
  description = "Enable image cleaner"
  type        = bool
  default     = false
}

variable "image_cleaner_interval_hours" {
  description = "Image cleaner interval in hours"
  type        = number
  default     = 168
}

variable "node_resource_group" {
  description = "Name of the node resource group"
  type        = string
  default     = null
}

variable "storage_profile" {
  description = "Storage profile configuration"
  type = object({
    blob_driver_enabled         = bool
    disk_driver_enabled         = bool
    file_driver_enabled         = bool
    snapshot_controller_enabled = bool
  })
  default = {
    blob_driver_enabled         = false
    disk_driver_enabled         = true
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }
}

variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    allowed = list(object({
      day   = string
      hours = list(number)
    }))
    not_allowed = list(object({
      end   = string
      start = string
    }))
  })
  default = null
}

variable "automatic_channel_upgrade" {
  description = "Automatic channel upgrade setting"
  type        = string
  default     = null
  validation {
    condition = var.automatic_channel_upgrade == null || contains(["patch", "rapid", "node-image", "stable"], var.automatic_channel_upgrade)
    error_message = "Automatic channel upgrade must be patch, rapid, node-image, or stable."
  }
}

variable "node_os_channel_upgrade" {
  description = "Node OS channel upgrade setting"
  type        = string
  default     = null
  validation {
    condition = var.node_os_channel_upgrade == null || contains(["Unmanaged", "SecurityPatch", "NodeImage"], var.node_os_channel_upgrade)
    error_message = "Node OS channel upgrade must be Unmanaged, SecurityPatch, or NodeImage."
  }
}

variable "acr_id" {
  description = "ID of the Azure Container Registry to attach"
  type        = string
  default     = null
}