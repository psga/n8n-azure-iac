#output "n8n_ip" {
#  value = azurerm_public_ip.n8n_ip.ip_address
#}
output "vm_private_ip" {
  value = azurerm_network_interface.n8n_nic.private_ip_address
}
output "vm_principal_id" {
  value = azurerm_linux_virtual_machine.n8n_vm.identity[0].principal_id
}

