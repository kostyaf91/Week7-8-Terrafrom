output "lb_backend_pool" {
  value = azurerm_lb_backend_address_pool.lb-backend-pool
}

output "lb_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}