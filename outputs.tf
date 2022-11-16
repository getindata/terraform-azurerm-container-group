output "name" {
  description = "Name of the container group"
  value       = one(azurerm_container_group.this[*].name)
}

output "id" {
  description = "ID of the container group"
  value       = one(azurerm_container_group.this[*].id)
}

output "resource_group_name" {
  description = "Name of the container group resource group"
  value       = one(azurerm_container_group.this[*].resource_group_name)
}

output "system_assigned_identity_principal_id" {
  description = "ID of the system assigned principal"
  value       = local.container_group_system_assigned_identity_principal_id
}

output "fqdn" {
  description = "The FQDN of the container group derived from `dns_name_label`"
  value       = one(azurerm_container_group.this[*].fqdn)
}

output "ip_address" {
  description = "The IP address allocated to the container group"
  value       = one(azurerm_container_group.this[*].ip_address)
}
