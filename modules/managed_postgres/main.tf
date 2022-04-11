resource "azurerm_private_dns_zone" "private_dns" {
  name                = "${var.tag}.postgres.database.azure.com"
  resource_group_name = var.rg.name
}
resource "azurerm_private_dns_zone_virtual_network_link" "dns-link" {
  name                  = "${var.tag}-vnet-zone-link.com"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns.name
  resource_group_name   = var.rg.name
  virtual_network_id    = var.vnet.id
}
resource "azurerm_postgresql_flexible_server" "postgres-flexible-server" {
  location               = var.rg.location
  name                   = "${var.tag}-postgres-flex-server"
  resource_group_name    = var.rg.name
  version                = "13"
  delegated_subnet_id    = var.private_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.private_dns.id
  administrator_login    = "postgres"
  administrator_password = var.postgres_password
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  zone                   = "1"
  depends_on             = [azurerm_private_dns_zone_virtual_network_link.dns-link]
}
resource "azurerm_postgresql_flexible_server_configuration" "postgres_config" {
  name       = "require_secure_transport"
  server_id  = azurerm_postgresql_flexible_server.postgres-flexible-server.id
  value      = "off"
}
