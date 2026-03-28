output "vnet_id" { value = azurerm_virtual_network.vnet.id }
output "vnet_name" { value = azurerm_virtual_network.vnet.name }
output "public_subnet_id" { value = azurerm_subnet.public_subnet.id }
output "private_subnet_id" { value = azurerm_subnet.private_subnet.id }
output "gateway_subnet_id" { value = azurerm_subnet.gateway_subnet.id }
