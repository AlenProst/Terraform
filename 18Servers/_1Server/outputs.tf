
output "resource_group_out" {
  value       = azurerm_resource_group.SRG.name
  description = ""
}

output "subnet_id_out" {
  value       = azurerm_subnet.SRG-subnet.id
  description = "description"
}

output "nsg_id_out" {
  value       = azurerm_network_security_group.SRG-NSG.id
  description = "description"
}

output "vn_id_out" {
  value       = azurerm_virtual_network.SRG-vnet.id
  description = "description"
}

output "vn_name_out" {
  value       = azurerm_virtual_network.SRG-vnet.name
  description = "description"
}
