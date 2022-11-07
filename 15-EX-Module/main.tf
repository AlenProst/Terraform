module "DC" {
  source = "./DC"
}

module "EX" {
  source = "./EX"
  rg_name = module.DC.rg_out
  subnet_id = module.DC.sn1_id_out
  nsg_id = module.DC.nsg_id_out
  depends_on=[module.DC]
}


