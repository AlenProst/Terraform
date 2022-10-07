resource "azurerm_resource_group" "RG" {
  location = var.location
  name     = "${var.base_name}RG"
}