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
  count               = var.vm_count
  name                = "ip_p-${count.index}"
  resource_group_name = azurerm_resource_group.first_tf_rg.name
  location            = var.tf_location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "aznetworkinterface" {
  count               = var.vm_count
  location            = var.tf_location
  name                = "nic-${count.index}"
  resource_group_name = azurerm_resource_group.first_tf_rg.name
  ip_configuration {
    name                          = "nic-${count.index}"
    subnet_id                     = azurerm_subnet.first_tf_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tf_public_ip[count.index].id
  }
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

resource "azurerm_network_interface_security_group_association" "tf_nsg_association" {
  count                     = var.vm_count
  network_interface_id      = azurerm_network_interface.aznetworkinterface[count.index].id
  network_security_group_id = azurerm_network_security_group.tf_NSG.id
}

resource "azurerm_linux_virtual_machine" "Linux-1" {
  count                     = var.vm_count
  name                = "x-${count.index}"
  resource_group_name   = azurerm_resource_group.first_tf_rg.name
  location            = var.tf_location
  size                = "Standard_B1ls"
  disable_password_authentication = "false"
  admin_username      = "adminuser"
  admin_password = "3m3rs0nF1t1pald!"
  network_interface_ids = [azurerm_network_interface.aznetworkinterface[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "vmext" {
    count                     = var.vm_count
    name                = "vmext-${count.index}"
    virtual_machine_id = azurerm_linux_virtual_machine.Linux-1[count.index].id
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"

    settings = <<SETTINGS
    {
        "script": "${filebase64("file.sh")}"
    }
    SETTINGS
}