#output "n8n_ip" {
#  value = azurerm_public_ip.n8n_ip.ip_address
#}
output "vm_private_ip" {
  value = azurerm_network_interface.n8n_nic.private_ip_address
}
