
resource "azurerm_public_ip" "ip2" {
  name                = "ip2"
  resource_group_name = var.rg_name
  location            = "westeurope"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "aznetworkinterface_1" {
  location            = "westeurope"
  name                = "aznetworkinterface_1"
  resource_group_name = var.rg_name
  ip_configuration {
    name                          = "aznetworkinterface_1ip"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.ip2.id
    private_ip_address            = "10.0.0.6"
  }
}

resource "azurerm_network_interface_security_group_association" "tf_nsg_association_1" {
  network_interface_id      = azurerm_network_interface.aznetworkinterface_1.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_windows_virtual_machine" "winvm2" {
  admin_password        = "P@ss2.rd1234"
  admin_username        = "azureuser"
  location              = "westeurope"
  name                  = "winvm2"
  network_interface_ids = [azurerm_network_interface.aznetworkinterface_1.id]
  resource_group_name   = var.rg_name
  size                  = "Standard_D11_v2"
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

resource "azurerm_virtual_machine_extension" "ex_extention" {
  name                       = "ex_extention"
  virtual_machine_id         = azurerm_windows_virtual_machine.winvm2.id
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
    template = "${file("./EX/install.ps1")}"
}


resource "time_sleep" "wait_300_seconds" {
  create_duration = "300s"
 depends_on = [azurerm_virtual_machine_extension.ex_extention]
}

variable admin_password {
  type        = string
  default     = "1"
  description = "description"
}

resource "azurerm_virtual_machine_extension" "domjoin" {
name = "domjoin"
virtual_machine_id = azurerm_windows_virtual_machine.winvm2.id
publisher = "Microsoft.Compute"
type = "JsonADDomainExtension"
type_handler_version = "1.3"
# What the settings mean: https://docs.microsoft.com/en-us/windows/desktop/api/lmjoin/nf-lmjoin-netjoindomain
settings = <<SETTINGS
{
"Name": "contoso.local",
"OUPath": "",
"User": "contoso.local\\azureuser",
"Restart": "true",
"Options": "3"
}
SETTINGS
protected_settings = <<PROTECTED_SETTINGS
{
"Password": "${var.admin_password}"
}
PROTECTED_SETTINGS
depends_on = [time_sleep.wait_300_seconds]
}



