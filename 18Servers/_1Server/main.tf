resource "azurerm_resource_group" "SRG" {
  location = var.location
  name     = "${var.resource_prefix}-SRG"
}

resource "azurerm_virtual_network" "SRG-vnet" {
  address_space       = var.SRG_address_space
  location            = var.location
  name                = "${var.resource_prefix}-SRG-vnet"
  resource_group_name = azurerm_resource_group.SRG.name
  #dns_servers         = [cidrhost(var.SRG_address_space_subnet, 10)]
}

resource "azurerm_subnet" "SRG-subnet" {
  name                 = "${var.resource_prefix}-SRG-subnet"
  resource_group_name  = azurerm_resource_group.SRG.name
  virtual_network_name = azurerm_virtual_network.SRG-vnet.name
  address_prefixes     = [var.SRG_address_space_subnet]
}

resource "azurerm_public_ip" "SRG-public_ip" {
  name                = "${var.resource_prefix}-SRG-Public_IP"
  resource_group_name = azurerm_resource_group.SRG.name
  location            = var.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "SRG-NIC" {
  location            = var.location
  name                = "${var.resource_prefix}-SRG-NIC"
  resource_group_name = azurerm_resource_group.SRG.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SRG-subnet.id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.SRG-public_ip.id
    private_ip_address            = cidrhost(var.SRG_address_space_subnet, 10)
  }
}

resource "azurerm_network_security_group" "SRG-NSG" {
  name                = "${var.resource_prefix}-SRG-NSG"
  location            = var.location
  resource_group_name = azurerm_resource_group.SRG.name
}

resource "azurerm_network_security_rule" "SRG-rule_1" {
  name                        = "SRG-rule_1"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.SRG.name
  network_security_group_name = azurerm_network_security_group.SRG-NSG.name
}

resource "azurerm_network_interface_security_group_association" "SRG-NSG_association" {
  network_interface_id      = azurerm_network_interface.SRG-NIC.id
  network_security_group_id = azurerm_network_security_group.SRG-NSG.id
}

resource "azurerm_windows_virtual_machine" "SRG-VM" {
  admin_password        = "P@ss2.rd1234"
  admin_username        = "azureuser"
  location              = var.location
  name                  = "${var.resource_prefix}-SRG-VM"
  network_interface_ids = [azurerm_network_interface.SRG-NIC.id]
  resource_group_name   = azurerm_resource_group.SRG.name
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

resource "azurerm_virtual_machine_extension" "SRG-VM_extention" {
  name                       = "extention"
  virtual_machine_id         = azurerm_windows_virtual_machine.SRG-VM.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.SRG-VM_template.rendered)}')) | Out-File -filepath install.ps1\" && powershell -ExecutionPolicy Unrestricted -File install.ps1"
  }
  SETTINGS
}

data "template_file" "SRG-VM_template" {
  template = file("./_1Server/install.ps1")
}


