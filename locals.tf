locals {
  # Get a name from the descriptor. If not available, use default naming convention.
  # Trim and replace function are used to avoid bare delimiters on both ends of the name and situation of adjacent delimiters.
  name_from_descriptor = trim(replace(
    lookup(module.this.descriptors, "azure-container-group", module.this.id),
    "/${module.this.delimiter}${module.this.delimiter}+/",
  module.this.delimiter), module.this.delimiter)

  location            = coalesce(one(data.azurerm_resource_group.this[*].location), var.location)
  resource_group_name = coalesce(one(data.azurerm_resource_group.this[*].name), var.resource_group_name)

  container_group_system_assigned_identity_principal_id = try(azurerm_container_group.this[0].identity[0].principal_id, "")
}
