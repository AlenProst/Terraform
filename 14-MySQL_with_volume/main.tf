resource "azurerm_resource_group" "rg1" {
  name     = "rg1"
  location = "West Europe"
}

resource "azurerm_storage_account" "SA" {
  name                     = "resonanceeznwekzapeqwe"
  resource_group_name      = azurerm_resource_group.rg1.name
  location                 = azurerm_resource_group.rg1.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

}

resource "azurerm_storage_share" "share1" {
  name                 = "share1"
  storage_account_name = azurerm_storage_account.SA.name
  quota                = 10

  acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
    }
  }
}

resource "azurerm_container_group" "c1" {
  name                = "c1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  ip_address_type     = "Public"
  dns_name_label      = "c0nt-label"
  os_type             = "Linux"

  container {
    name   = "flask-app"
    image  = "alenprost/hard"
    cpu    = "0.5"
    memory = "1.5"
    
    
    ports {
      port     = 5000
      protocol = "TCP"
    }
  }

  container {
    name   = "mysql"
    image  = "mysql"
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {"MYSQL_DATABASE"="mydb", "MYSQL_ROOT_PASSWORD"="mypass"}
     ports {
      port     = 3306
      protocol = "TCP"
    }
    volume {
      name       = "data"
      mount_path = "/var/lib/mysql"
      read_only  = false
      share_name = azurerm_storage_share.share1.name

      storage_account_name = azurerm_storage_account.SA.name
      storage_account_key  = azurerm_storage_account.SA.primary_access_key
    }
  }
}