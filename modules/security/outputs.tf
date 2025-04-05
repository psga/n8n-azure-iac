output "key_vault_id" {
  value = azurerm_key_vault.kv.id
}
output "n8n_encryption_key" {
  value = azurerm_key_vault_secret.n8n_encryption_key.value
}
output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}
