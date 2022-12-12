variable "resource_group_name" {
  description = "Azure resource group name where resources will be deployed"
  type        = string
}

variable "location" {
  description = "Location where resources will be deployed. If not provided it will be read from resource group location"
  type        = string
  default     = null
}

variable "descriptor_name" {
  description = "Name of the descriptor used to form a resource name"
  type        = string
  default     = "azure-container-group"
}

variable "diagnostic_settings" {
  description = "Enables diagnostics settings for a resource and streams the logs and metrics to any provided sinks"
  type = object({
    enabled               = optional(bool, false)
    logs_destinations_ids = optional(list(string), [])
  })
  default = {}
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
    secure_environment_variables_from_key_vault = optional(map(object({
      key_vault_id = string
      name         = string
    })), {})
    volumes = optional(map(object({
      mount_path = string
      read_only  = optional(bool, false)
      empty_dir  = optional(bool)
      git_repo = optional(object({
        url       = string
        directory = optional(string)
        revision  = optional(string)
      }))
      secret               = optional(map(string))
      storage_account_name = optional(string)
      storage_account_key  = optional(string)
      share_name           = optional(string)
    })), {})
  }))

  validation {
    condition = alltrue(flatten([
      for container in var.containers : [
        for volume in container.volumes :
        (length([
          for v in [volume.secret, volume.storage_account_name, volume.git_repo, volume.empty_dir] : v
          if v != null
        ]) == 1)
      ]
    ]))
    error_message = "Exactly one of empty_dir volume, git_repo volume, secret volume or storage account volume (share_name, storage_account_name, and storage_account_key) must be specified"
  }
}

variable "exposed_ports" {
  description = "It can only contain ports that are also exposed on one or more containers in the group"
  type = list(object({
    port     = number
    protocol = optional(string, "TCP")
  }))
  default = []
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

variable "restart_policy" {
  description = "Restart policy for the container group. Allowed values are `Always`, `Never`, `OnFailure`. Defaults to `Always`"
  type        = string
  default     = "Always"

  validation {
    condition     = contains(["Always", "Never", "OnFailure"], var.restart_policy)
    error_message = "Allowed values are `Always`, `Never` or `OnFailure`"
  }
}

variable "identity" {
  description = "Managed identity block. For type possible values are: SystemAssigned and UserAssigned"
  type = object({
    enabled      = optional(bool, false)
    type         = optional(string, "SystemAssigned")
    identity_ids = optional(list(string), [])
    user_assigned_identity = optional(object({
      enabled         = optional(bool, false)
      descriptor_name = optional(string, "azure-managed-service-identity")
    }), {})
    role_assignments = optional(list(object({
      scope                = string
      role_definition_name = string
    })), [])
  })
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
