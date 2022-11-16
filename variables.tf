variable "resource_group_name" {
  description = "Azure resource group name where resources will be deployed"
  type        = string
}

variable "location" {
  description = "Location where resources will be deployed. If not provided it will be read from resource group location"
  type        = string
  default     = null
}

variable "containers" {
  description = "List of containers that will be running in the container group"
  type = map(object({
    image  = string
    cpu    = number
    memory = number
    ports = optional(list(object({
      port     = number
      protocol = optional(string, "TCP")
    })), [])
    commands                     = optional(list(string), [])
    environment_variables        = optional(map(string), {})
    secure_environment_variables = optional(map(string), {})
    volumes = optional(map(object({
      mount_path = string
      secret     = map(string)
    })), {})
  }))
}

variable "subnet_ids" {
  description = "The subnet resource IDs for a container group. At the moment it supports 1 subnet maximum"
  type        = list(string)
  default     = []
}

variable "dns_name_label" {
  description = "The DNS label/name for the container group's IP. If not provided it will use the name of the resource"
  type        = string
  default     = null
}

variable "dns_name_servers" {
  description = "DNS name servers configured with containers"
  type        = list(string)
  default     = []
}

variable "identity" {
  description = "Managed identity block. For type possible values are: SystemAssigned and UserAssigned"
  type = object({
    type         = optional(string, "SystemAssigned")
    identity_ids = optional(list(string), [])
    system_assigned_identity_role_assignments = optional(list(object({
      scope                = string
      role_definition_name = string
    })), [])
  })
  default = null
}

variable "image_registry_credential" {
  description = "Credentials for ACR, so the images can be pulled by the container instance"
  type = list(object({
    username = string
    password = string
    server   = string
  }))
  default = []
}

variable "container_diagnostics_log_analytics" {
  description = "Log Analytics workspace to be used with container logs"
  type = object({
    workspace_id  = string
    workspace_key = string
    log_type      = optional(string, "ContainerInsights")
  })
  default = null
}

variable "container_group_diagnostics_setting" {
  description = "Azure Monitor diagnostics for container group resource"
  type = object({
    workspace_resource_id = optional(string)
  })
  default = null
}
