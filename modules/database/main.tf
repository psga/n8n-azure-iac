resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_postgresql_flexible_server" "db_server" {
  name                = "server-n8n-db-${random_string.suffix.result}" # Nombre único
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "13" # n8n run perfect in Postgres 13 o 14
  zone                = "1"  # We can chose the zone where the DB will be set

  delegated_subnet_id = var.private_subnet_id
  private_dns_zone_id = azurerm_private_dns_zone.dns_postgres.id

  public_network_access_enabled = false

  administrator_login    = "n8nadmin"
  administrator_password = random_password.db_password.result

  storage_mb                   = 32768             # 32 GB mínimo
  sku_name                     = "B_Standard_B1ms" # (Burstable)
  geo_redundant_backup_enabled = false

  depends_on = [azurerm_private_dns_zone_virtual_network_link.dns_link]
}

resource "azurerm_private_dns_zone" "dns_postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "dns-link-postgres"
  private_dns_zone_name = azurerm_private_dns_zone.dns_postgres.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
}

# Create the specific DB for n8n in the server
resource "azurerm_postgresql_flexible_server_database" "n8ndb" {
  name      = "n8n_db"
  server_id = azurerm_postgresql_flexible_server.db_server.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
