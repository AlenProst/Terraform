resource "azurerm_resource_group" "rg2" {
  location = "westeurope"
  name     = "rg2"
}

resource "azurerm_virtual_network" "vn1" {
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  name                = "vn1"
  resource_group_name = azurerm_resource_group.rg2.name
  dns_servers         = ["10.0.0.4"]
}

resource "azurerm_subnet" "sn1" {
  name                 = "sn1"
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vn1.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "public1" {
  name                = "public1"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = "westeurope"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "NIC1" {
  location            = "westeurope"
  name                = "NIC1"
  resource_group_name = azurerm_resource_group.rg2.name
  ip_configuration {
    name                          = "NIC_IP"
    subnet_id                     = azurerm_subnet.sn1.id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.public1.id
    private_ip_address            = "10.0.0.4"
  }
}

# resource "azurerm_network_security_group" "tf_NSG" {
#   name                = "tf_NSG"
#   location            = "westeurope"
#   resource_group_name = azurerm_resource_group.rg2.name

#   security_rule {
#     name                       = "rule_1"
#     priority                   = 100
#     direction                  = "Inbound"
#     access                     = "Allow"
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     destination_port_range     = "*"
#     source_address_prefix      = "*"
#     destination_address_prefix = "*"
#   }
# }

resource "azurerm_network_security_group" "tf_NSG" {
  name                = "tf_NSG"
  location            =  "westeurope"
  resource_group_name = azurerm_resource_group.rg2.name
}

resource "azurerm_network_security_rule" "rule_1" {
  name                        = "rule_1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg2.name
  network_security_group_name = azurerm_network_security_group.tf_NSG.name
}

resource "azurerm_network_interface_security_group_association" "tf_nsg_association" {
  network_interface_id      = azurerm_network_interface.NIC1.id
  network_security_group_id = azurerm_network_security_group.tf_NSG.id
}

resource "azurerm_windows_virtual_machine" "winvm1" {
  admin_password        = "P@ss2.rd1234"
  admin_username        = "azureuser"
  location              = "westeurope"
  name                  = "winvm1"
  network_interface_ids = [azurerm_network_interface.NIC1.id]
  resource_group_name   = azurerm_resource_group.rg2.name
  size                  = "Standard_B2ms"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  
}

resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  name                       = "vm_extension_install_iis"
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
    template = "${file("./DC/install.ps1")}"
} 

resource "time_sleep" "wait_200_seconds" {
  create_duration = "200s"
  depends_on = [azurerm_virtual_machine_extension.vm_extension_install_iis]
}