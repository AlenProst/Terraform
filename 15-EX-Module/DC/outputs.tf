
output rg_out {
  value       = azurerm_resource_group.rg2.name
  description = ""
}

output sn1_id_out {
  value       = azurerm_subnet.sn1.id
  description = "description"

}

output nsg_id_out {
  value       = azurerm_network_security_group.tf_NSG.id
  description = "description"
}

