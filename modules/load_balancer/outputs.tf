output "gateway_ip" {
  value = azurerm_public_ip.gw_ip.ip_address
}
