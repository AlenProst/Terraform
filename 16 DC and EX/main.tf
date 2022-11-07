resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = var.resource_group
}

resource "azurerm_virtual_network" "vn1" {
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  name                = var.vn_name
  resource_group_name = azurerm_resource_group.rg.name
  dns_servers         = ["10.0.0.4"]
}

resource "azurerm_subnet" "sn1" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn1.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "public1" {
  name                = var.public_ip_1
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "NIC1" {
  location            = var.location
  name                = var.nic_name_1
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "NIC_IP"
    subnet_id                     = azurerm_subnet.sn1.id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.public1.id
    private_ip_address            = "10.0.0.4"
  }
}

resource "azurerm_network_security_group" "tf_NSG" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "rule_1" {
  name                        = var.rule_nsg_name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.tf_NSG.name
}

resource "azurerm_network_interface_security_group_association" "tf_nsg_association" {
  network_interface_id      = azurerm_network_interface.NIC1.id
  network_security_group_id = azurerm_network_security_group.tf_NSG.id
}

resource "azurerm_windows_virtual_machine" "winvm1" {
  admin_password        = "P@ss2.rd1234"
  admin_username        = "azureuser"
  location              = var.location
  name                  = var.DC_name
  network_interface_ids = [azurerm_network_interface.NIC1.id]
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.vm1_size
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.sku
    version   = "latest"
  }


}

resource "azurerm_virtual_machine_extension" "extention_dc" {
  name                       = var.extention_name
  virtual_machine_id         = azurerm_windows_virtual_machine.winvm1.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.tf.rendered)}')) | Out-File -filepath install.ps1\" && powershell -ExecutionPolicy Unrestricted -File install.ps1"
  }
  SETTINGS
}

data "template_file" "tf" {
  template = file("./install.ps1")
}

resource "time_sleep" "wait_200_seconds" {
  create_duration = "200s"
  depends_on      = [azurerm_virtual_machine_extension.extention_dc]
}

###########


resource "azurerm_public_ip" "public2" {
  name                = var.public_ip_2
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "NIC2" {
  location            = var.location
  name                = var.nic_name_2
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "NIC2ip"
    subnet_id                     = azurerm_subnet.sn1.id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.public2.id
    private_ip_address            = "10.0.0.6"
  }
}

resource "azurerm_network_interface_security_group_association" "tf_nsg_association_1" {
  network_interface_id      = azurerm_network_interface.NIC2.id
  network_security_group_id = azurerm_network_security_group.tf_NSG.id
}

resource "azurerm_windows_virtual_machine" "ex" {
  admin_password        = "P@ss2.rd1234"
  admin_username        = "azureuser"
  location              = var.location
  name                  = var.exchange_name
  network_interface_ids = [azurerm_network_interface.NIC2.id]
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.exchange_size
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.sku_ex
    version   = "latest"
  }


}

resource "azurerm_virtual_machine_extension" "ex_extention" {
  name                       = "ex_extention"
  virtual_machine_id         = azurerm_windows_virtual_machine.ex.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.tf1.rendered)}')) | Out-File -filepath install1.ps1\" && powershell -ExecutionPolicy Unrestricted -File install1.ps1"
  }
  SETTINGS
}

data "template_file" "tf1" {
  template = file("./install1.ps1")
}


resource "time_sleep" "wait_300_seconds" {
  create_duration = "300s"
  depends_on      = [azurerm_virtual_machine_extension.ex_extention]
}



resource "azurerm_virtual_machine_extension" "domjoin" {
  name                 = "domjoin"
  virtual_machine_id   = azurerm_windows_virtual_machine.ex.id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  settings             = <<SETTINGS
{
"Name": "asdfg.dnsabr.com",
"OUPath": "",
"User": "asdfg\\azureuser",
"Restart": "true",
"Options": "3"
}
SETTINGS
  protected_settings   = <<PROTECTED_SETTINGS
{
"Password": "${var.admin_password}"
}
PROTECTED_SETTINGS
  depends_on           = [time_sleep.wait_300_seconds]
}



