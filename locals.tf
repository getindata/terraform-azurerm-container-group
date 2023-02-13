locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = trim(replace(
    lookup(module.this.descriptors, var.descriptor_name, module.this.id),
    "/${module.this.delimiter}${module.this.delimiter}+/",
  module.this.delimiter), module.this.delimiter)

  msi_name_from_descriptor = trim(replace(
    lookup(module.this.descriptors, var.identity.user_assigned_identity.descriptor_name, module.this.id),
    "/${module.this.delimiter}${module.this.delimiter}+/",
  module.this.delimiter), module.this.delimiter)

  identity = {
    type         = var.identity.user_assigned_identity.enabled ? "UserAssigned" : var.identity.type
    identity_ids = concat(azurerm_user_assigned_identity.this[*].id, var.identity.identity_ids)
  }

  location            = coalesce(one(data.azurerm_resource_group.this[*].location), var.location)
  resource_group_name = coalesce(one(data.azurerm_resource_group.this[*].name), var.resource_group_name)

  secrets_from_volumes = merge([for container_name, container in var.containers : merge([
    for volume_name, volume in container.volumes : {
      for secret in volume.secret_from_key_vault : "${container_name}/${volume_name}/${secret.name}" => {
        key_vault_id = secret.key_vault_id
        name         = secret.name
      } if secret != {}
    }
    ]...)
  ]...)

  container_group_identity_principal_id = var.identity.enabled ? coalesce(
    one(azurerm_user_assigned_identity.this[*].principal_id),
    try(azurerm_container_group.this[0].identity[0].principal_id, "")
  ) : ""
}
