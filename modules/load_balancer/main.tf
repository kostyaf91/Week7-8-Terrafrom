#Public IP creation
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "lb_public_ip"
  location            = var.rg.location
  resource_group_name = var.rg.name
  allocation_method   = "Static"
  sku = "Standard"
}
# Load balancer creation
resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = var.rg.location
  resource_group_name = var.rg.name
  sku = "Standard"

  frontend_ip_configuration {
    name                 = "lb-public-ip"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}
resource "azurerm_lb_backend_address_pool" "lb-backend-pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "lb-backend-address-pool"
}
resource "azurerm_lb_probe" "lb-probe" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "lb-probe-8080"
  port                = 8080
  protocol = "HTTP"
  resource_group_name = var.rg.name
  request_path = "/"
}
resource "azurerm_lb_rule" "lb_rule_8080" {
  backend_port                   = 8080
  frontend_ip_configuration_name = azurerm_lb.lb.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb-backend-pool.id]
  frontend_port                  = 8080
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "lb_rule_8080"
  protocol                       = "Tcp"
  resource_group_name            = var.rg.name
  probe_id = azurerm_lb_probe.lb-probe.id
}
