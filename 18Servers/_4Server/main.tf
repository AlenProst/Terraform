resource "azurerm_resource_group" "SRG-2" {
  location = var.location
  name     = "${var.prefix}-SRG-2"
}

resource "azurerm_virtual_network" "SRG-2-vnet" {
  address_space       = var.SRG-2_address_space
  location            = var.location
  name                = "${var.prefix}-SRG-2-vnet"
  resource_group_name = azurerm_resource_group.SRG-2.name
  dns_servers         = ["10.0.0.10"]
}

resource "azurerm_subnet" "SRG-2-subnet" {
  name                 = "${var.prefix}-SRG-2-subnet"
  resource_group_name  = azurerm_resource_group.SRG-2.name
  virtual_network_name = azurerm_virtual_network.SRG-2-vnet.name
  address_prefixes     = [var.SRG-2_address_space_subnet]
}

resource "azurerm_public_ip" "SRG-2-public_ip" {
  name                = "${var.prefix}-SRG-2-Public_IP"
  resource_group_name = azurerm_resource_group.SRG-2.name
  location            = var.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "SRG-2-NIC" {
  location            = var.location
  name                = "${var.prefix}-SRG-2-NIC"
  resource_group_name = azurerm_resource_group.SRG-2.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SRG-2-subnet.id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.SRG-2-public_ip.id
    private_ip_address            = cidrhost(var.SRG-2_address_space_subnet, 10)
  }
}

resource "azurerm_network_security_group" "SRG-2-NSG" {
  name                = "${var.prefix}-SRG-2-NSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.SRG-2.name
}

resource "azurerm_network_security_rule" "SRG-2-rule_1" {
  name                        = "SRG-2-rule_1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.SRG-2.name
  network_security_group_name = azurerm_network_security_group.SRG-2-NSG.name
}

resource "azurerm_network_interface_security_group_association" "SRG-2-NSG_association" {
  network_interface_id      = azurerm_network_interface.SRG-2-NIC.id
  network_security_group_id = azurerm_network_security_group.SRG-2-NSG.id
}

resource "azurerm_windows_virtual_machine" "SRG-2-VM" {
  admin_password        = "P@ss2.rd1234"
  admin_username        = "azureuser"
  location              = var.location
  name                  = "${var.prefix}-SRG-2-VM"
  network_interface_ids = [azurerm_network_interface.SRG-2-NIC.id]
  resource_group_name   = azurerm_resource_group.SRG-2.name
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

resource "azurerm_virtual_machine_extension" "SRG-2-VM_extention" {
  name                       = "extention"
  virtual_machine_id         = azurerm_windows_virtual_machine.SRG-2-VM.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.SRG-2_template.rendered)}')) | Out-File -filepath install.ps1\" && powershell -ExecutionPolicy Unrestricted -File install.ps1"
  }
  SETTINGS
}

data "template_file" "SRG-2_template" {
  template = file("./_4Server/install.ps1")
}


resource "azurerm_virtual_network_peering" "SRG-2_peer" {
  name                         = "${var.prefix}-SRG_2_peer"
  resource_group_name          = azurerm_resource_group.SRG-2.name
  virtual_network_name         = azurerm_virtual_network.SRG-2-vnet.name
  remote_virtual_network_id    = var.romote_SRG_VN_id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "SRG_2_peer_1" {
  name                         = "${var.prefix}-SRG_2_peer_1"
  resource_group_name          = var.resource_group_remote
  virtual_network_name         = var.remote_SRG_VN_name
  remote_virtual_network_id    = azurerm_virtual_network.SRG-2-vnet.id
  allow_virtual_network_access = true
}
