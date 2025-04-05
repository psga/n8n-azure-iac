data "azurerm_client_config" "current" {}

resource "random_string" "kv_name" {
  length  = 8
  special = false
  upper   = false
}

# create the key vault 
resource "azurerm_key_vault" "kv" {
  name                        = "kv-n8n-${random_string.kv_name.result}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  # Access Policy 
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]
  }
}

resource "random_password" "n8n_enc_key" {
  length  = 24
  special = true
}

resource "azurerm_key_vault_secret" "n8n_encryption_key" {
  name         = "n8n-encryption-key"
  value        = random_password.n8n_enc_key.result
  key_vault_id = azurerm_key_vault.kv.id
}
# Save the DB password in the Vault 
resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.kv.id
}
