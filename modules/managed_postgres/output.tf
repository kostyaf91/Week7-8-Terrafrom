output "postgres_password" {
  value = azurerm_postgresql_flexible_server.postgres-flexible-server.administrator_password
}