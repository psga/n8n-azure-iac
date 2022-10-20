resource "azurerm_dns_zone" "main" {
  name                = "tu-dominio.com" # El que compraste en Namecheap
  resource_group_name = var.resource_group_name
}
