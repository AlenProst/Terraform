resource "azurerm_resource_group" "first_tf_rg" {
  location = var.tf_location
  name     = var.rg_name
}

resource "azurerm_virtual_network" "first_tf_network" {
  address_space       = ["10.0.0.0/16"]
  location            = var.tf_location
  name                = var.vn_name
  resource_group_name = azurerm_resource_group.first_tf_rg.name
}

resource "azurerm_subnet" "first_tf_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.first_tf_rg.name
  virtual_network_name = azurerm_virtual_network.first_tf_network.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_public_ip" "tf_public_ip" {
  name                = "tf_public_ip"
  resource_group_name = azurerm_resource_group.first_tf_rg.name
  location            = var.tf_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_security_group" "tf_NSG" {
  name                = "tf_NSG"
  location            = var.tf_location
  resource_group_name = azurerm_resource_group.first_tf_rg.name

  security_rule {
    name                       = "rule_1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "aznetworkinterface" {
  location            = var.tf_location
  name                = "aznetworkinterface"
  resource_group_name = azurerm_resource_group.first_tf_rg.name
  ip_configuration {
    name                          = "aznetworkinterfaceip"
    subnet_id                     = azurerm_subnet.first_tf_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "tf_nsg_association" {
  network_interface_id      = azurerm_network_interface.aznetworkinterface.id
  network_security_group_id = azurerm_network_security_group.tf_NSG.id
}

resource "azurerm_windows_virtual_machine" "winvm1" {
  admin_password        = "P@ss2.rd1234"
  admin_username        = "azureuser"
  location              = var.tf_location
  name                  = "winvm1"
  network_interface_ids = [azurerm_network_interface.aznetworkinterface.id]
  resource_group_name   = azurerm_resource_group.first_tf_rg.name
  size                  = "Standard_B1s"
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
    template = "${file("install.ps1")}"
} 


resource "azurerm_network_interface" "aznetworkinterface1" {
  location            = var.tf_location
  name                = "aznetworkinterface1"
  resource_group_name = azurerm_resource_group.first_tf_rg.name
  ip_configuration {
    name                          = "aznetworkinterfaceip1"
    subnet_id                     = azurerm_subnet.first_tf_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "tf_nsg_association1" {
  network_interface_id      = azurerm_network_interface.aznetworkinterface1.id
  network_security_group_id = azurerm_network_security_group.tf_NSG.id
}

resource "azurerm_windows_virtual_machine" "winvm2" {
  admin_password        = "P@ss2.rd1234"
  admin_username        = "azureuser"
  location              = var.tf_location
  name                  = "winvm2"
  network_interface_ids = [azurerm_network_interface.aznetworkinterface1.id]
  resource_group_name   = azurerm_resource_group.first_tf_rg.name
  size                  = "Standard_B1s"
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

resource "azurerm_virtual_machine_extension" "vm_extension_install_iis1" {
  name                       = "vm_extension_install_iis1"
  virtual_machine_id         = azurerm_windows_virtual_machine.winvm2.id
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
    template = "${file("install2.ps1")}"
} 


resource "azurerm_lb" "LB-L4" {
  name                = "LB-L4"
  location            = var.tf_location
  sku                 = "Standard"
  resource_group_name = azurerm_resource_group.first_tf_rg.name

  frontend_ip_configuration {
    name                 = "LB-L4-PublicIP"
    public_ip_address_id = azurerm_public_ip.tf_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "LB-L4-backendpool" {
  loadbalancer_id = azurerm_lb.LB-L4.id
  name            = "LB-L4-backendpool"
}

resource "azurerm_network_interface_backend_address_pool_association" "NIC_winvm1" {
  network_interface_id    = azurerm_network_interface.aznetworkinterface.id
  ip_configuration_name   = "aznetworkinterfaceip"
  backend_address_pool_id = azurerm_lb_backend_address_pool.LB-L4-backendpool.id
}

resource "azurerm_network_interface_backend_address_pool_association" "winvm2_NIC" {
  network_interface_id    = azurerm_network_interface.aznetworkinterface1.id
  ip_configuration_name   = "aznetworkinterfaceip1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.LB-L4-backendpool.id
}

resource "azurerm_lb_rule" "rule_HTTP" {
  loadbalancer_id                = azurerm_lb.LB-L4.id
  name                           = "rule_HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LB-L4-PublicIP"
  backend_address_pool_ids       = ["${azurerm_lb_backend_address_pool.LB-L4-backendpool.id}"]
  probe_id                       = azurerm_lb_probe.HTTP-probe.id
}

resource "azurerm_lb_probe" "HTTP-probe" {
  loadbalancer_id     = azurerm_lb.LB-L4.id
  name                = "HTTP-probe"
  port                = 80
}

