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

module "file_share" {
  source = "./file_share"
  storage_account = module.storage_account.stg_act_name_out
  rg_name = module.W10.rg_name_out
}




