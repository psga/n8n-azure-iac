resource "azurerm_dns_zone" "main" {
  name                = "pusuga.me" # El que compraste en Namecheap
  resource_group_name = var.resource_group_name
}

resource "azurerm_dns_a_record" "n8n" {
  name                = "n8n"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [var.gateway_ip]
}
