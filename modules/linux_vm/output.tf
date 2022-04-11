output "ni" {
  value = azurerm_network_interface.NI
}

output "password" {
  value =azurerm_linux_virtual_machine.linux_vm.admin_password
}

output "ansible_ip" {
  value = azurerm_linux_virtual_machine.linux_vm.public_ip_address
}