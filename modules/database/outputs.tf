output "db_host" {
  value = azurerm_postgresql_flexible_server.db_server.fqdn
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}
