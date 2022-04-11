output "resource_group" {
  value = azurerm_resource_group.Main
}

output "vnet" {
  value = azurerm_virtual_network.vnet
}

output "public_subnet" {
  value = azurerm_subnet.public_subnet
}

output "private_subnet" {
  value = azurerm_subnet.private_subnet
}