resource "azurerm_public_ip" "SRG-public_ip" {
  name                = "${var.resource_prefix}-SRG-Public_IP"
  resource_group_name = var.Server2_resource_group
  location            = var.location
  allocation_method   = "Static"
}


resource "azurerm_network_interface" "SRG-NIC" {
  location            = var.location
  name                = "${var.resource_prefix}-SRG-NIC"
  resource_group_name = var.Server2_resource_group
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.Server2_subnet_ID
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.SRG-public_ip.id
    private_ip_address            = cidrhost(var.SRG_address_space_subnet, 11)
  }
}

resource "azurerm_network_interface_security_group_association" "SRG-NSG_association" {
  network_interface_id      = azurerm_network_interface.SRG-NIC.id
  network_security_group_id = var.Server2_NSG
}

resource "azurerm_windows_virtual_machine" "SRG-VM" {
  admin_password        = "P@ss2.rd1234"
  admin_username        = "azureuser"
  location              = var.location
  name                  = "${var.resource_prefix}-SRGVM"
  network_interface_ids = [azurerm_network_interface.SRG-NIC.id]
  resource_group_name   = var.Server2_resource_group
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
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.SRG-NSG_template.rendered)}')) | Out-File -filepath install.ps1\" && powershell -ExecutionPolicy Unrestricted -File install.ps1"
  }
  SETTINGS
}

data "template_file" "SRG-NSG_template" {
  template = file("./_2Server/install.ps1")
}
