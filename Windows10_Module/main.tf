module "W10" {
  source = "./W10"
  base_name = "TF1"
  location = "westeurope"
}

module "storage_account" {
  source = "./storage_account"
  base_name = "TF1"
  location = "westeurope"
  rg_name = module.W10.rg_name_out
}


