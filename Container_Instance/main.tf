resource "azurerm_resource_group" "rg1" {
  name     = "g1"
  location = "West Europe"
}

resource "azurerm_container_group" "c1" {
  name                = "c1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  container {
    name   = "note-app-falsk"
    image  = "alenprost/notes_app_no_db_1"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 5000
      protocol = "TCP"
    }
  }
}