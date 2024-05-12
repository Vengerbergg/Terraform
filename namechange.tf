provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "firstmatrix" {
  name     = "rg-firstmatrix"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vpc" {
  name                = "vpc"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.firstmatrix.location
  resource_group_name = azurerm_resource_group.firstmatrix.name
}

resource "azurerm_subnet" "sub" {
  name                 = "var.vpc"
  resource_group_name  = azurerm_resource_group.firstmatrix.name
  virtual_network_name = azurerm_virtual_network.vpc.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "sg" {
  name                = "sg-firstmatrix"
  location            = azurerm_resource_group.firstmatrix.location
  resource_group_name = azurerm_resource_group.firstmatrix.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "firstmatrixinterface" {
  name                = "firstmatrixinterface"
  location            = azurerm_resource_group.firstmatrix.location
  resource_group_name = azurerm_resource_group.firstmatrix.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm-firstmatrix" {
  name                = "vm-firstmatrix"
  resource_group_name = azurerm_resource_group.firstmatrix.name
  location            = azurerm_resource_group.firstmatrix.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.firstmatrixinterface.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("C:\\Users\\ivanc\\.ssh\\id_rsa.pub")
  }

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
