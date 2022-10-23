resource "azurerm_dns_zone" "main" {
  name                = "pusuga.me" # El que compraste en Namecheap
  resource_group_name = var.resource_group_name
}
