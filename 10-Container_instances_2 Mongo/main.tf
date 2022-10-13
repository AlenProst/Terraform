resource "azurerm_resource_group" "rg1" {
  name     = "rg1"
  location = "West Europe"
}

resource "azurerm_container_group" "c1" {
  name                = "c1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  ip_address_type     = "Public"
  dns_name_label      = "c0nt-label"
  os_type             = "Linux"

  container {
    name   = "mongo-express"
    image  = "mongo-express"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {"ME_CONFIG_MONGODB_ADMINUSERNAME"="admin", "ME_CONFIG_MONGODB_ADMINPASSWORD"="password", "ME_CONFIG_MONGODB_SERVER"="localhost:27017" }
    
    
    ports {
      port     = 8081
      protocol = "TCP"
    }
  }

  container {
    name   = "mongo"
    image  = "mongo"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {"MONGO_INITDB_ROOT_USERNAME"="admin", "MONGO_INITDB_ROOT_PASSWORD"="password"}
     ports {
      port     = 27017
      protocol = "TCP"
    }
  }

  tags = {
    environment = "testing"
  }
}