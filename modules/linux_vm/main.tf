# Public IP creation
resource "azurerm_public_ip" "public-ip" {
  name                = "public-ip"
  location            = var.rg.location
  resource_group_name = var.rg.name
  allocation_method   = "Static"
}
# Network interface creation
resource "azurerm_network_interface" "NI" {
  location            = var.rg.location
  name                = var.ni_name
  resource_group_name = var.rg.name

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id = var.subnet.id
    public_ip_address_id = azurerm_public_ip.public-ip.id
  }
}
resource "azurerm_linux_virtual_machine" "linux_vm" {
  admin_username        = "ubuntu"
  location              = var.rg.location
  name                  = var.linux_vm_name
  network_interface_ids = [azurerm_network_interface.NI.id]
  resource_group_name   = var.rg.name
  size                  = "Standard_B2s"
  #user_data                       = filebase64(var.user_data_file)
  disable_password_authentication = "false"
  admin_password = var.password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}