resource "azurerm_storage_share" "share1" {
  name                 = "share1"
  storage_account_name = var.storage_account
  quota                = 10

  acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
    }
  }
}

data "azurerm_storage_account" "key" {
  name                = var.storage_account
  resource_group_name = var.rg_name
}
