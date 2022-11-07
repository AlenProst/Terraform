module "_1Server" {
  source          = "./_1Server"
  resource_prefix = "VM1"
  location        = "centralindia"
  vm1_size        = "Standard_DS1_v2"
  sku             = "2019-Datacenter"
}

module "_2Server" {
  source                 = "./_2Server"
  resource_prefix        = "VM2EX2019"
  location               = "centralindia"
  vm1_size               = "Standard_DS11-1_v2"
  sku                    = "2019-Datacenter"
  Server2_resource_group = module._1Server.resource_group_out
  Server2_subnet_ID      = module._1Server.subnet_id_out
  Server2_NSG            = module._1Server.nsg_id_out
  depends_on             = [module._1Server]

}

module "_3Server" {
  source                 = "./_3Server"
  resource_prefix        = "VM3EX2019"
  location               = "centralindia"
  vm1_size               = "Standard_DS11-1_v2"
  sku                    = "2019-Datacenter"
  Server3_resource_group = module._1Server.resource_group_out
  Server3_subnet_ID      = module._1Server.subnet_id_out
  Server3_NSG            = module._1Server.nsg_id_out
  depends_on             = [module._2Server]

}

module "_4Server" {
  source                = "./_4Server"
  prefix                = "VMW"
  location              = "canadacentral"
  vm1_size              = "Standard_B1ms"
  sku                   = "2019-Datacenter"
  romote_SRG_VN_id      = module._1Server.vn_id_out
  remote_SRG_VN_name    = module._1Server.vn_name_out
  resource_group_remote = module._1Server.resource_group_out
  depends_on            = [module._3Server]
}




