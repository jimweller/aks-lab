variable "project_name" {
  description = "Name of the project used for resource naming"
  type        = string
  default     = "jim-aks-lab"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "West US 2"
}

variable "tfstate_resource_group_name" {
  description = "Name of the resource group for Terraform state storage"
  type        = string
  default     = "rg-jim-aks-lab-tfstate"
}

variable "tfstate_container_name" {
  description = "Name of the storage container for Terraform state files"
  type        = string
  default     = "tfstate"
}

variable "deploy_token" {
  description = "Deployment token for unique resource naming. If null, a random token will be generated."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    project    = "aks-lab"
    managed_by = "terraform"
    purpose    = "tfstate-backend"
  }
}